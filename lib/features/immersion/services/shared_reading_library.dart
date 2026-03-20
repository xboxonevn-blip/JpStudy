import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_reading_models.dart';

class SharedReadingLibrary {
  const SharedReadingLibrary();

  Future<List<ImmersionArticle>> loadImmersionArticles() async {
    final assetPaths = await _loadLessonAssetPaths();
    final articles = <ImmersionArticle>[];
    for (final path in assetPaths) {
      final expectedLevel = _levelFromAssetPath(path);
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final wrappedArticles = decoded['articles'];
          if (wrappedArticles is List) {
            articles.addAll(
              wrappedArticles.whereType<Map>().map(
                (item) => ImmersionArticle.fromJson(
                  _asMap(item),
                  expectedLevel: expectedLevel,
                  fallbackSource: ImmersionArticle.localSourceLabel,
                ),
              ),
            );
          } else {
            articles.add(
              ImmersionArticle.fromJson(
                decoded,
                expectedLevel: expectedLevel,
                fallbackSource: ImmersionArticle.localSourceLabel,
              ),
            );
          }
        }
      } catch (_) {
        continue;
      }
    }
    articles.sort(_compareImmersionArticles);
    return articles;
  }

  Future<List<JlptReadingPassage>> loadJlptPassages() async {
    final articles = await loadImmersionArticles();
    final byLevel = <String, List<ImmersionArticle>>{};
    for (final article in articles) {
      if (!_isReadableArticle(article)) {
        continue;
      }
      byLevel
          .putIfAbsent(article.level, () => <ImmersionArticle>[])
          .add(article);
    }

    final passages = <JlptReadingPassage>[];
    for (final article in articles) {
      if (!_isReadableArticle(article)) {
        continue;
      }
      final peers = byLevel[article.level] ?? const <ImmersionArticle>[];
      passages.add(_toJlptPassage(article, peers));
    }
    passages.sort(_comparePassages);
    return passages;
  }

  Future<List<String>> _loadLessonAssetPaths() async {
    return _fallbackLessonAssetPaths();
  }

  List<String> _fallbackLessonAssetPaths() {
    const lessonRanges = <String, List<int>>{
      'n5': [1, 25],
      'n4': [26, 50],
      'n3': [51, 75],
    };
    final paths = <String>[];
    for (final entry in lessonRanges.entries) {
      final level = entry.key;
      final start = entry.value[0];
      final end = entry.value[1];
      for (var lessonId = start; lessonId <= end; lessonId++) {
        final padded = lessonId.toString().padLeft(2, '0');
        paths.add('assets/data/content/immersion/$level/lesson_$padded.json');
      }
    }
    return paths;
  }

  JlptReadingPassage _toJlptPassage(
    ImmersionArticle article,
    List<ImmersionArticle> sameLevelPeers,
  ) {
    final paragraphTexts = _paragraphTexts(article);
    final titleOptions = _titleOptionSet(article, sameLevelPeers);
    final detailParagraphIndex = paragraphTexts.length > 1 ? 1 : 0;
    final detailOptions = _paragraphOptionSet(
      article: article,
      peers: sameLevelPeers,
      paragraphIndex: detailParagraphIndex,
    );
    final endingOptions = _paragraphOptionSet(
      article: article,
      peers: sameLevelPeers,
      paragraphIndex: paragraphTexts.length - 1,
    );
    final endingQuestion = _closingQuestion(paragraphTexts.last);

    return JlptReadingPassage(
      id: article.id,
      title: article.title,
      level: article.level,
      recommendedMinutes: _recommendedMinutes(article.level, paragraphTexts),
      body: paragraphTexts.join('\n'),
      questions: [
        JlptReadingQuestion(
          id: '${article.id}-q1',
          type: JlptReadingQuestionType.mainIdea,
          prompt: 'この文章のテーマとして最も近いものはどれですか。',
          options: titleOptions.options,
          correctIndex: titleOptions.correctIndex,
          explanation: 'タイトルと本文全体の流れから判断します。',
        ),
        JlptReadingQuestion(
          id: '${article.id}-q2',
          type: JlptReadingQuestionType.detail,
          prompt: '本文の内容と合うものはどれですか。',
          options: detailOptions.options,
          correctIndex: detailOptions.correctIndex,
          explanation: '第${detailParagraphIndex + 1}段落の内容と照らして確認します。',
        ),
        JlptReadingQuestion(
          id: '${article.id}-q3',
          type: endingQuestion.type,
          prompt: endingQuestion.prompt,
          options: endingOptions.options,
          correctIndex: endingOptions.correctIndex,
          explanation: '最後の段落の内容を手がかりに判断します。',
        ),
      ],
    );
  }

  _OptionSet _titleOptionSet(
    ImmersionArticle article,
    List<ImmersionArticle> sameLevelPeers,
  ) {
    final options = <String>[article.title];
    for (final peer in sameLevelPeers) {
      if (peer.id == article.id) {
        continue;
      }
      if (!options.contains(peer.title)) {
        options.add(peer.title);
      }
      if (options.length >= 4) {
        break;
      }
    }
    if (options.length < 4) {
      for (final extra in const <String>['日常生活', '学習の工夫', '社会の話題']) {
        if (!options.contains(extra)) {
          options.add(extra);
        }
        if (options.length >= 4) {
          break;
        }
      }
    }
    return _OptionSet(options: options.take(4).toList(), correctIndex: 0);
  }

  _OptionSet _paragraphOptionSet({
    required ImmersionArticle article,
    required List<ImmersionArticle> peers,
    required int paragraphIndex,
  }) {
    final currentParagraphs = _paragraphTexts(article);
    final options = <String>[currentParagraphs[paragraphIndex]];
    for (final peer in peers) {
      if (peer.id == article.id) {
        continue;
      }
      final paragraphs = _paragraphTexts(peer);
      if (paragraphs.isEmpty) {
        continue;
      }
      final option =
          paragraphs[paragraphIndex < paragraphs.length
              ? paragraphIndex
              : paragraphs.length - 1];
      if (!options.contains(option)) {
        options.add(option);
      }
      if (options.length >= 4) {
        break;
      }
    }

    if (options.length < 4) {
      for (final fallback in currentParagraphs) {
        if (!options.contains(fallback)) {
          options.add(fallback);
        }
        if (options.length >= 4) {
          break;
        }
      }
    }

    return _OptionSet(options: options.take(4).toList(), correctIndex: 0);
  }

  _ClosingQuestion _closingQuestion(String closingParagraph) {
    final looksLikePlan = RegExp(
      r'(たい|つもり|ようにしている|ことにしている|予定|大切にしたい)',
    ).hasMatch(closingParagraph);
    if (looksLikePlan) {
      return const _ClosingQuestion(
        type: JlptReadingQuestionType.inference,
        prompt: '筆者がこれから大切にしたいこととして最も近いものはどれですか。',
      );
    }
    return const _ClosingQuestion(
      type: JlptReadingQuestionType.detail,
      prompt: '文末の内容と合うものはどれですか。',
    );
  }

  int _recommendedMinutes(String level, List<String> paragraphs) {
    final textLength = paragraphs.join().runes.length;
    final base = switch (level) {
      'N5' => 5,
      'N4' => 7,
      'N3' => 9,
      'N2' => 11,
      'N1' => 12,
      _ => 8,
    };
    if (textLength >= 260) {
      return base + 1;
    }
    return base;
  }

  List<String> _paragraphTexts(ImmersionArticle article) {
    return article.paragraphs
        .map((paragraph) => paragraph.map((token) => token.surface).join())
        .where((text) => text.trim().isNotEmpty)
        .toList(growable: false);
  }

  bool _isReadableArticle(ImmersionArticle article) {
    return article.title.trim().isNotEmpty &&
        article.paragraphs.any((paragraph) => paragraph.isNotEmpty);
  }

  Map<String, dynamic> _asMap(Map item) {
    return item.map((key, value) => MapEntry('$key', value));
  }

  String? _levelFromAssetPath(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final match = RegExp(r'/immersion/(n[1-5])/').firstMatch(normalizedPath);
    final rawLevel = match?.group(1);
    if (rawLevel == null) {
      return null;
    }
    return ImmersionArticle.normalizeOfficialLevel(rawLevel);
  }

  int _comparePassages(JlptReadingPassage a, JlptReadingPassage b) {
    final levelOrder = <String, int>{
      'N5': 0,
      'N4': 1,
      'N3': 2,
      'N2': 3,
      'N1': 4,
    };
    final levelDelta = (levelOrder[a.level] ?? 999).compareTo(
      levelOrder[b.level] ?? 999,
    );
    if (levelDelta != 0) {
      return levelDelta;
    }
    return a.id.compareTo(b.id);
  }

  int _compareImmersionArticles(ImmersionArticle a, ImmersionArticle b) {
    final levelOrder = <String, int>{
      'N5': 0,
      'N4': 1,
      'N3': 2,
      'N2': 3,
      'N1': 4,
    };
    final levelDelta = (levelOrder[a.level] ?? 999).compareTo(
      levelOrder[b.level] ?? 999,
    );
    if (levelDelta != 0) {
      return levelDelta;
    }
    return a.id.compareTo(b.id);
  }
}

class _OptionSet {
  const _OptionSet({required this.options, required this.correctIndex});

  final List<String> options;
  final int correctIndex;
}

class _ClosingQuestion {
  const _ClosingQuestion({required this.type, required this.prompt});

  final JlptReadingQuestionType type;
  final String prompt;
}
