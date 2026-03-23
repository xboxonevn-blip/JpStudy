import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/vocab/widgets/flashcard_widget.dart';

class VocabScreen extends ConsumerStatefulWidget {
  const VocabScreen({super.key});

  @override
  ConsumerState<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends ConsumerState<VocabScreen> {
  bool _isFlashcardMode = false;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final levelSuffix = level == null ? '' : ' (${level.shortLabel})';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${_title(language)}$levelSuffix'),
        actions: [
          if (level != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _isFlashcardMode ? Icons.list_rounded : Icons.style_rounded,
                ),
                tooltip: _toggleTooltip(language, _isFlashcardMode),
                onPressed: () {
                  setState(() {
                    _isFlashcardMode = !_isFlashcardMode;
                  });
                },
              ),
            ),
        ],
      ),
      body: level == null
          ? Center(child: Text(language.selectLevelToViewVocab))
          : _VocabContent(
              language: language,
              level: level,
              isFlashcardMode: _isFlashcardMode,
              onToggleMode: () {
                setState(() {
                  _isFlashcardMode = !_isFlashcardMode;
                });
              },
            ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Words';
      case AppLanguage.vi:
        return 'Từ';
      case AppLanguage.ja:
        return '単語';
    }
  }

  String _toggleTooltip(AppLanguage language, bool isFlashcardMode) {
    switch (language) {
      case AppLanguage.en:
        return isFlashcardMode ? 'Show list' : 'Show cards';
      case AppLanguage.vi:
        return isFlashcardMode ? 'Xem danh sách' : 'Xem thẻ';
      case AppLanguage.ja:
        return isFlashcardMode ? '一覧表示' : 'カード表示';
    }
  }
}

class _VocabContent extends ConsumerWidget {
  const _VocabContent({
    required this.language,
    required this.level,
    required this.isFlashcardMode,
    required this.onToggleMode,
  });

  final AppLanguage language;
  final StudyLevel level;
  final bool isFlashcardMode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabPreviewProvider(level.shortLabel));
    final dueTermsAsync = ref.watch(allDueTermsProvider);
    final nextReviewAsync = ref.watch(nextVocabReviewProvider);

    return vocabAsync.when(
      data: (dataItems) {
        final items = dataItems
            .map(
              (e) => VocabItem(
                id: e.id,
                term: e.term,
                reading: e.reading,
                meaning: e.meaning,
                meaningEn: e.meaningEn,
                kanjiMeaning: null,
                level: e.level,
              ),
            )
            .toList();

        final dueTerms = dueTermsAsync.valueOrNull ?? const [];
        final nextReview = nextReviewAsync.valueOrNull;
        final preview = items.take(6).toList();

        if (items.isEmpty) {
          return AppPageShell(
            child: AppFeatureCard(
              icon: Icons.translate_rounded,
              title: _heroTitle(language),
              subtitle: _emptySubtitle(language),
              secondaryLabel: _goLibraryLabel(language),
              onSecondaryTap: () => context.push('/library'),
            ),
          );
        }

        return AppPageShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFeatureCard(
                icon: Icons.translate_rounded,
                title: _heroTitle(language),
                subtitle: _heroSubtitle(language, itemCount: items.length, dueCount: dueTerms.length),
                primaryLabel: language.reviewAction,
                onPrimaryTap: () => context.push('/vocab/review'),
                secondaryLabel: _toggleLabel(language, isFlashcardMode),
                onSecondaryTap: onToggleMode,
                status: AppStatusChip(
                  label: dueTerms.isNotEmpty
                      ? language.reviewTermsDueLabel(dueTerms.length)
                      : _nextReviewLabel(language, nextReview),
                  tone: dueTerms.isNotEmpty ? AppStatusTone.warning : AppStatusTone.neutral,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppMetricPill(
                      label: _metricCollectionLabel(language),
                      value: '${items.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppMetricPill(
                      label: _metricDueLabel(language),
                      value: '${dueTerms.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppMetricPill(
                      label: _metricModeLabel(language),
                      value: isFlashcardMode ? _cardsModeLabel(language) : _listModeLabel(language),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppSectionHeader(
                title: _sectionTitle(language),
                caption: _sectionCaption(language, isFlashcardMode),
                actionLabel: _switchModeAction(language, isFlashcardMode),
                onActionTap: onToggleMode,
              ),
              const SizedBox(height: 10),
              if (isFlashcardMode)
                ...preview.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FlashcardWidget(item: item, language: language),
                  ),
                )
              else
                ...preview.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCompactRow(
                      icon: Icons.translate_rounded,
                      title: item.term,
                      subtitle: _subtitleForItem(item, language),
                      status: shouldShowReading(term: item.term, reading: item.reading)
                          ? AppStatusChip(label: item.reading!.trim())
                          : null,
                      onTap: () => context.push('/vocab/review'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(language.loadErrorLabel)),
    );
  }

  String _heroTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Vocab';
      case AppLanguage.vi:
        return 'Từ vựng';
      case AppLanguage.ja:
        return '語彙';
    }
  }

  String _heroSubtitle(AppLanguage language, {required int itemCount, required int dueCount}) {
    switch (language) {
      case AppLanguage.en:
        return dueCount > 0
            ? '$dueCount due words are waiting. Review first, then browse the current level set of $itemCount words.'
            : 'Browse the current level set of $itemCount words or flip through cards in a calmer study surface.';
      case AppLanguage.vi:
        return dueCount > 0
            ? 'Có $dueCount từ đến hạn đang chờ. Ôn trước rồi duyệt bộ $itemCount từ của cấp hiện tại.'
            : 'Duyệt bộ $itemCount từ của cấp hiện tại hoặc chuyển sang chế độ thẻ để học nhẹ và tập trung hơn.';
      case AppLanguage.ja:
        return dueCount > 0
            ? '$dueCount 件の期限語彙が待っています。先に復習してから現在レベルの $itemCount 語を確認しましょう。'
            : '現在レベルの $itemCount 語を一覧で見たり、カードで落ち着いて学べます。';
    }
  }

  String _emptySubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No words are available for this level yet.';
      case AppLanguage.vi:
        return 'Hiện chưa có từ nào cho cấp này.';
      case AppLanguage.ja:
        return 'このレベルで利用できる単語はまだありません。';
    }
  }

  String _goLibraryLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Open library';
      case AppLanguage.vi:
        return 'Mở thư viện';
      case AppLanguage.ja:
        return 'ライブラリを開く';
    }
  }

  String _toggleLabel(AppLanguage language, bool isFlashcardMode) {
    switch (language) {
      case AppLanguage.en:
        return isFlashcardMode ? 'Cards mode' : 'List mode';
      case AppLanguage.vi:
        return isFlashcardMode ? 'Chế độ thẻ' : 'Chế độ danh sách';
      case AppLanguage.ja:
        return isFlashcardMode ? 'カード表示' : '一覧表示';
    }
  }

  String _metricCollectionLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Collection',
    AppLanguage.vi => 'Bộ từ',
    AppLanguage.ja => '収録',
  };

  String _metricDueLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due',
    AppLanguage.vi => 'Đến hạn',
    AppLanguage.ja => '期限',
  };

  String _metricModeLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Mode',
    AppLanguage.vi => 'Chế độ',
    AppLanguage.ja => '表示',
  };

  String _cardsModeLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Cards',
    AppLanguage.vi => 'Thẻ',
    AppLanguage.ja => 'カード',
  };

  String _listModeLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'List',
    AppLanguage.vi => 'Danh sách',
    AppLanguage.ja => '一覧',
  };

  String _sectionTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Preview',
    AppLanguage.vi => 'Xem trước',
    AppLanguage.ja => 'プレビュー',
  };

  String _sectionCaption(AppLanguage language, bool isFlashcardMode) => switch (language) {
    AppLanguage.en => isFlashcardMode ? 'Flip a few cards before the real review session.' : 'Scan a few entries before jumping into review.',
    AppLanguage.vi => isFlashcardMode ? 'Lật thử vài thẻ trước khi vào phiên review thật.' : 'Lướt vài mục trước khi vào phiên review.',
    AppLanguage.ja => isFlashcardMode ? '本番の復習前に数枚だけカードをめくれます。' : '本番の復習前に数件だけ眺められます。',
  };

  String _switchModeAction(AppLanguage language, bool isFlashcardMode) => switch (language) {
    AppLanguage.en => isFlashcardMode ? 'Show list' : 'Show cards',
    AppLanguage.vi => isFlashcardMode ? 'Xem danh sách' : 'Xem thẻ',
    AppLanguage.ja => isFlashcardMode ? '一覧表示' : 'カード表示',
  };

  String _nextReviewLabel(AppLanguage language, DateTime? nextReview) {
    if (nextReview == null) {
      return switch (language) {
        AppLanguage.en => 'Ready now',
        AppLanguage.vi => 'Sẵn sàng',
        AppLanguage.ja => '準備完了',
      };
    }
    final now = DateTime.now();
    final days = nextReview.difference(now).inDays;
    if (days <= 0) {
      return switch (language) {
        AppLanguage.en => 'Today',
        AppLanguage.vi => 'Hôm nay',
        AppLanguage.ja => '今日',
      };
    }
    return switch (language) {
      AppLanguage.en => 'in $days day${days == 1 ? '' : 's'}',
      AppLanguage.vi => 'sau $days ngày',
      AppLanguage.ja => '$days 日後',
    };
  }

  String _subtitleForItem(VocabItem item, AppLanguage language) {
    final meaning = item.displayMeaning(language).trim();
    final reading = item.reading?.trim() ?? '';
    if (reading.isNotEmpty && shouldShowReading(term: item.term, reading: item.reading)) {
      return '$meaning • $reading';
    }
    return meaning;
  }
}
