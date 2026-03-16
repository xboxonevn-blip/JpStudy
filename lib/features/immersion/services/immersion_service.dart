import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/immersion_article.dart';

enum ImmersionSource { local, nhkEasy }

class ImmersionService {
  static const _assetPath = 'assets/data/content/immersion/immersion_samples.json';
  static const nhkSourceLabel = 'NHK Easy';
  static const nhkLevelLabel = 'Easy';
  static const watanocSourceLabel = 'Watanoc';
  static const watanocLevelLabel = 'N5-N4';
  static const matchaSourceLabel = 'MATCHA Easy';
  static const matchaLevelLabel = 'Easy';
  static const tadokuSourceLabel = 'Tadoku';
  static const tadokuLevelLabel = 'GR';
  static const _nhkTopListUrl =
      'https://www3.nhk.or.jp/news/easy/top-list.json';
  static const _nhkNewsListUrl =
      'https://www3.nhk.or.jp/news/easy/news-list.json';
  static const _watanocPostsUrl = 'https://watanoc.com/wp-json/wp/v2/posts';
  static const _matchaEasyFeedUrl = 'https://matcha-jp.com/easy/feed';
  static const _tadokuBookFeedUrl =
      'https://tadoku.org/japanese/?post_type=book&feed=rss2';
  static const Duration _listCacheTtl = Duration(hours: 6);
  static const Duration _articleCacheTtl = Duration(days: 7);
  static const Duration _requestTimeout = Duration(seconds: 8);
  static const Map<String, String> _requestHeaders = {
    'Accept': 'application/json,text/plain,*/*',
    'User-Agent': 'JpStudy/2.0',
  };

  Future<List<ImmersionArticle>> loadLocalSamples() async {
    final articles = <ImmersionArticle>[];
    const lessonRanges = <String, List<int>>{
      'n5': [1, 25],
      'n4': [26, 50],
      'n3': [51, 75],
      'n2': [76, 90],
      'n1': [91, 100],
    };

    // 1. Load legacy sample file if exists (optional, keeping for backward compat)
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['articles'] as List<dynamic>? ?? const [];
      articles.addAll(list.map((e) => ImmersionArticle.fromJson(e)).toList());
    } catch (_) {
      // Ignore if missing
    }

    // 2. Load new structured lessons (lesson_01.json ... lesson_100.json)
    for (final entry in lessonRanges.entries) {
      final level = entry.key;
      final startLesson = entry.value[0];
      final endLesson = entry.value[1];
      for (int i = startLesson; i <= endLesson; i++) {
        final paddedId = i.toString().padLeft(2, '0');
        final path = 'assets/data/content/immersion/$level/lesson_$paddedId.json';
        try {
          final raw = await rootBundle.loadString(path);
          final json = jsonDecode(raw);
          // Support both single object and wrapper format
          if (json is Map<String, dynamic>) {
            if (json.containsKey('articles')) {
              final list = json['articles'] as List;
              articles.addAll(
                list.map((e) => ImmersionArticle.fromJson(e)).toList(),
              );
            } else {
              // Single article file
              articles.add(ImmersionArticle.fromJson(json));
            }
          }
        } catch (_) {
          // File doesn't exist, skip
          continue;
        }
      }
    }

    // Sort by ID or Level/PublishedAt if needed
    // articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return articles;
  }

  Future<List<ImmersionArticle>> loadNhkEasySummaries({
    bool forceRefresh = false,
    int limit = 12,
  }) async {
    if (!forceRefresh) {
      final cached = await _readCacheList();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final items = await _fetchNhkList();
    final summaries = <ImmersionArticle>[];
    final seen = <String>{};
    for (final item in items) {
      final id = _string(item['news_id'] ?? item['id'] ?? item['newsId']);
      if (id == null || id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      final title = _string(item['title']) ?? id;
      final timeRaw =
          _string(item['news_prearranged_time']) ??
          _string(item['news_published_time']) ??
          _string(item['publish_time']) ??
          _string(item['date']);
      final publishedAt = _parseDate(timeRaw) ?? DateTime.now();

      summaries.add(
        ImmersionArticle(
          id: id,
          title: title,
          titleFurigana: null,
          level: nhkLevelLabel,
          source: nhkSourceLabel,
          publishedAt: publishedAt,
          paragraphs: const [],
          translation: null,
        ),
      );
      if (summaries.length >= limit) break;
    }

    if (summaries.isNotEmpty) {
      await _writeCacheList(summaries);
      return summaries;
    }

    // NHK Easy JSON currently requires JWT auth. Build a fallback pool.
    final fallback = await _loadFallbackArticles(limit: limit);
    if (fallback.isNotEmpty) {
      await _writeCacheList(fallback);
      return fallback;
    }

    final cached = await _readCacheList(ignoreTtl: true);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return summaries;
  }

  Future<List<ImmersionArticle>> loadWatanocSummaries({int limit = 12}) async {
    final requestUrl = Uri.parse(_watanocPostsUrl).replace(
      queryParameters: {
        'categories': '4',
        'per_page': '$limit',
        '_fields': 'id,date,title,content',
      },
    );
    final response = await _safeGet(requestUrl.toString());
    if (response == null || response.statusCode != 200) {
      return const [];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      return const [];
    }
    if (decoded is! List) {
      return const [];
    }

    final articles = <ImmersionArticle>[];
    for (final raw in decoded) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final id = _string(map['id']);
      if (id == null || id.isEmpty) continue;

      final titleContainer = map['title'];
      final rawTitle = titleContainer is Map
          ? _string(titleContainer['rendered'])
          : null;
      final title = _decodeEntities(_stripTags(rawTitle ?? '')).trim();
      if (title.isEmpty) continue;

      final contentContainer = map['content'];
      final rawContent = contentContainer is Map
          ? _string(contentContainer['rendered'])
          : null;
      final paragraphs = rawContent == null
          ? const <List<ImmersionToken>>[]
          : _parseHtmlParagraphs(rawContent);
      if (paragraphs.isEmpty) continue;

      final publishedAt = _parseDate(_string(map['date'])) ?? DateTime.now();
      articles.add(
        ImmersionArticle(
          id: 'watanoc_$id',
          title: title,
          titleFurigana: null,
          level: watanocLevelLabel,
          source: watanocSourceLabel,
          publishedAt: publishedAt,
          paragraphs: paragraphs,
          translation: null,
        ),
      );
      if (articles.length >= limit) {
        break;
      }
    }

    return articles;
  }

  Future<List<ImmersionArticle>> loadMatchaEasySummaries({
    int limit = 8,
  }) async {
    final response = await _safeGet(_matchaEasyFeedUrl);
    if (response == null || response.statusCode != 200) {
      return const [];
    }
    final items = _extractRssItems(response.body);
    if (items.isEmpty) return const [];

    final articles = <ImmersionArticle>[];
    final seen = <String>{};
    for (final item in items) {
      final link = item['link'];
      final titleRaw = item['title'];
      final content = item['content'] ?? item['description'] ?? '';
      if (link == null || titleRaw == null || content.trim().isEmpty) {
        continue;
      }
      final id = _extractMatchaArticleId(link);
      if (id == null || seen.contains(id)) continue;
      seen.add(id);

      final title = _decodeEntities(_stripTags(titleRaw)).trim();
      if (title.isEmpty) continue;
      final paragraphs = _parseHtmlParagraphs(content);
      if (paragraphs.isEmpty) continue;

      final publishedAt =
          _parseDate(item['pubDate']) ??
          _parseRssDate(item['pubDate']) ??
          DateTime.now();

      articles.add(
        ImmersionArticle(
          id: 'matcha_$id',
          title: title,
          titleFurigana: null,
          level: matchaLevelLabel,
          source: matchaSourceLabel,
          publishedAt: publishedAt,
          paragraphs: paragraphs,
          translation: null,
        ),
      );
      if (articles.length >= limit) {
        break;
      }
    }
    return articles;
  }

  Future<List<ImmersionArticle>> loadTadokuSummaries({int limit = 6}) async {
    final response = await _safeGet(_tadokuBookFeedUrl);
    if (response == null || response.statusCode != 200) {
      return const [];
    }
    final items = _extractRssItems(response.body);
    if (items.isEmpty) return const [];

    final articles = <ImmersionArticle>[];
    final seen = <String>{};
    for (final item in items) {
      final link = item['link'];
      final titleRaw = item['title'];
      if (link == null || titleRaw == null) continue;
      final id = _extractTadokuBookId(link);
      if (id == null || seen.contains(id)) continue;
      seen.add(id);

      final detailResponse = await _safeGet(link);
      if (detailResponse == null || detailResponse.statusCode != 200) {
        continue;
      }
      final level = _extractTadokuLevel(detailResponse.body);
      final paragraphs = _extractTadokuParagraphs(detailResponse.body);
      if (paragraphs.isEmpty) continue;

      final title = _decodeEntities(_stripTags(titleRaw)).trim();
      if (title.isEmpty) continue;

      final publishedAt =
          _parseDate(item['pubDate']) ??
          _parseRssDate(item['pubDate']) ??
          DateTime.now();

      articles.add(
        ImmersionArticle(
          id: 'tadoku_$id',
          title: title,
          titleFurigana: null,
          level: level ?? tadokuLevelLabel,
          source: tadokuSourceLabel,
          publishedAt: publishedAt,
          paragraphs: paragraphs,
          translation: null,
        ),
      );
      if (articles.length >= limit) {
        break;
      }
    }
    return articles;
  }

  Future<List<ImmersionArticle>> _loadFallbackArticles({int limit = 12}) async {
    final aggregated = <ImmersionArticle>[];
    final seen = <String>{};

    void append(List<ImmersionArticle> incoming) {
      for (final article in incoming) {
        if (seen.contains(article.id)) continue;
        aggregated.add(article);
        seen.add(article.id);
        if (aggregated.length >= limit) break;
      }
    }

    var perSource = (limit / 3).ceil();
    if (perSource < 2) perSource = 2;
    if (perSource > limit) perSource = limit;
    append(await loadMatchaEasySummaries(limit: perSource));
    if (aggregated.length < limit) {
      append(await loadWatanocSummaries(limit: limit - aggregated.length));
    }
    if (aggregated.length < limit) {
      append(await loadTadokuSummaries(limit: perSource));
    }
    if (aggregated.length < limit) {
      append(await loadMatchaEasySummaries(limit: limit - aggregated.length));
    }
    if (aggregated.length < limit) {
      append(await loadWatanocSummaries(limit: limit - aggregated.length));
    }

    return aggregated.take(limit).toList();
  }

  Future<ImmersionArticle?> loadNhkArticleDetail(
    String newsId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _readCacheArticle(newsId);
      if (cached != null) {
        return cached;
      }
    }

    final url = 'https://www3.nhk.or.jp/news/easy/$newsId/$newsId.json';
    final response = await _safeGet(url);
    if (response == null || response.statusCode != 200) {
      return _readCacheArticle(newsId, ignoreTtl: true);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final article = _parseNhkArticle(decoded, fallbackId: newsId);
    if (article == null) {
      return _readCacheArticle(newsId, ignoreTtl: true);
    }
    await _writeCacheArticle(article);
    return article;
  }

  Future<List<Map<String, dynamic>>> _fetchNhkList() async {
    final urls = [_nhkTopListUrl, _nhkNewsListUrl];
    for (final url in urls) {
      final response = await _safeGet(url);
      if (response == null || response.statusCode != 200) {
        continue;
      }
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        continue;
      }
      final items = _extractListItems(decoded);
      if (items.isNotEmpty) {
        return items;
      }
    }
    return [];
  }

  Future<http.Response?> _safeGet(String url) async {
    try {
      return await http
          .get(Uri.parse(url), headers: _requestHeaders)
          .timeout(_requestTimeout);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _extractListItems(dynamic decoded) {
    final items = <Map<String, dynamic>>[];
    if (decoded is List) {
      for (final entry in decoded) {
        if (entry is Map) {
          final hasListValue = entry.values.any((value) => value is List);
          if (hasListValue) {
            for (final value in entry.values) {
              if (value is List) {
                for (final item in value) {
                  if (item is Map<String, dynamic>) {
                    items.add(item);
                  } else if (item is Map) {
                    items.add(Map<String, dynamic>.from(item));
                  }
                }
              }
            }
          } else {
            items.add(Map<String, dynamic>.from(entry));
          }
        }
      }
    } else if (decoded is Map) {
      final data = decoded['data'];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            items.add(item);
          } else if (item is Map) {
            items.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }
    return items;
  }

  ImmersionArticle? _parseNhkArticle(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final id =
        _string(root['news_id'] ?? root['id'] ?? fallbackId) ?? fallbackId;
    final titleWithRuby = _string(root['title_with_ruby']);
    final title =
        _string(root['title']) ??
        (titleWithRuby != null ? _stripTags(titleWithRuby) : null) ??
        id;

    final titleFurigana = titleWithRuby == null
        ? null
        : _renderRubyText(titleWithRuby);

    final timeRaw =
        _string(root['news_prearranged_time']) ??
        _string(root['news_published_time']) ??
        _string(root['publish_time']) ??
        _string(root['date']);
    final publishedAt = _parseDate(timeRaw) ?? DateTime.now();

    final dict = _parseWordList(root['word_list'] ?? root['dictionary']);

    final paragraphs = <List<ImmersionToken>>[];
    final body = root['body'] ?? root['news_body'] ?? root['text'];
    if (body is List) {
      for (final entry in body) {
        final text = _extractBodyText(entry);
        if (text == null || text.trim().isEmpty) {
          continue;
        }
        paragraphs.addAll(_parseParagraphs(text, dict));
      }
    } else if (body is String) {
      paragraphs.addAll(_parseParagraphs(body, dict));
    }

    if (paragraphs.isEmpty) {
      final outline = _string(root['outline'] ?? root['outline_with_ruby']);
      if (outline != null && outline.trim().isNotEmpty) {
        paragraphs.addAll(_parseParagraphs(outline, dict));
      }
    }

    return ImmersionArticle(
      id: id,
      title: title,
      titleFurigana: titleFurigana,
      level: nhkLevelLabel,
      source: nhkSourceLabel,
      publishedAt: publishedAt,
      paragraphs: paragraphs,
      translation: null,
    );
  }

  String? _extractBodyText(dynamic entry) {
    if (entry is String) {
      return entry;
    }
    if (entry is Map) {
      return _string(entry['text_with_ruby']) ??
          _string(entry['text']) ??
          _string(entry['body']) ??
          _string(entry['content']);
    }
    return null;
  }

  List<List<ImmersionToken>> _parseParagraphs(
    String html,
    Map<String, _NhkWord> dict,
  ) {
    final normalized = html.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
    final parts = normalized.split(RegExp(r'\n+'));
    final paragraphs = <List<ImmersionToken>>[];
    for (final part in parts) {
      final tokens = _parseRubyText(part, dict);
      if (tokens.isNotEmpty) {
        paragraphs.add(tokens);
      }
    }
    return paragraphs;
  }

  List<ImmersionToken> _parseRubyText(String html, Map<String, _NhkWord> dict) {
    final tokens = <ImmersionToken>[];
    final rubyRegex = RegExp(r'<ruby[^>]*>.*?</ruby>', dotAll: true);
    var cursor = 0;
    for (final match in rubyRegex.allMatches(html)) {
      if (match.start > cursor) {
        final before = html.substring(cursor, match.start);
        tokens.addAll(_plainTokens(before, dict));
      }
      final ruby = match.group(0) ?? '';
      final token = _tokenFromRuby(ruby, dict);
      if (token != null) {
        tokens.add(token);
      }
      cursor = match.end;
    }
    if (cursor < html.length) {
      tokens.addAll(_plainTokens(html.substring(cursor), dict));
    }
    return tokens.where((t) => t.surface.trim().isNotEmpty).toList();
  }

  List<List<ImmersionToken>> _parseHtmlParagraphs(
    String html, {
    bool stripTipso = true,
  }) {
    var normalized = html;
    if (stripTipso) {
      normalized = normalized.replaceAllMapped(
        RegExp(
          r'''<span[^>]*class=["'][^"']*tipso[^"']*["'][^>]*>(.*?)</span>''',
          caseSensitive: false,
          dotAll: true,
        ),
        (match) => match.group(1) ?? '',
      );
    }

    normalized = normalized
        .replaceAll(
          RegExp(
            r'<(script|style)[^>]*>.*?</\1>',
            caseSensitive: false,
            dotAll: true,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), ' ')
        .replaceAll(RegExp(r'</(p|div|li|h[1-6])>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    final plain = _decodeEntities(
      _stripTags(normalized),
    ).replaceAll('\u00A0', ' ').replaceAll(RegExp(r'[ \t]+'), ' ');

    final paragraphs = <List<ImmersionToken>>[];
    for (final line in plain.split(RegExp(r'\n+'))) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final tokens = _plainTokens(trimmed, const <String, _NhkWord>{});
      if (tokens.isNotEmpty) {
        paragraphs.add(tokens);
      }
    }
    return paragraphs;
  }

  ImmersionToken? _tokenFromRuby(String rubyHtml, Map<String, _NhkWord> dict) {
    final rtRegex = RegExp(r'<rt[^>]*>(.*?)</rt>', dotAll: true);
    final rbRegex = RegExp(r'<rb[^>]*>(.*?)</rb>', dotAll: true);
    final reading = rtRegex
        .allMatches(rubyHtml)
        .map((m) => _stripTags(m.group(1) ?? ''))
        .join();
    final rbMatches = rbRegex.allMatches(rubyHtml).toList();
    String surface;
    if (rbMatches.isNotEmpty) {
      surface = rbMatches.map((m) => _stripTags(m.group(1) ?? '')).join();
    } else {
      surface = _stripTags(
        rubyHtml
            .replaceAll(rtRegex, '')
            .replaceAll(RegExp(r'<rp[^>]*>.*?</rp>'), ''),
      );
    }
    surface = surface.trim();
    if (surface.isEmpty) return null;
    final dictWord = dict[surface];
    return ImmersionToken(
      surface: surface,
      reading: reading.isEmpty ? dictWord?.reading : reading,
      meaningEn: dictWord?.meaningEn,
      meaningVi: null,
    );
  }

  List<ImmersionToken> _plainTokens(String text, Map<String, _NhkWord> dict) {
    final cleaned = _decodeEntities(_stripTags(text));
    final tokens = <ImmersionToken>[];
    final buffer = StringBuffer();
    for (final rune in cleaned.runes) {
      final char = String.fromCharCode(rune);
      if (_isWhitespace(char)) {
        _flushBuffer(buffer, tokens, dict);
        continue;
      }
      if (_isPunctuation(char)) {
        _flushBuffer(buffer, tokens, dict);
        tokens.add(_tokenFromSurface(char, dict));
        continue;
      }
      buffer.write(char);
    }
    _flushBuffer(buffer, tokens, dict);
    return tokens;
  }

  void _flushBuffer(
    StringBuffer buffer,
    List<ImmersionToken> tokens,
    Map<String, _NhkWord> dict,
  ) {
    if (buffer.isEmpty) return;
    final surface = buffer.toString();
    tokens.add(_tokenFromSurface(surface, dict));
    buffer.clear();
  }

  ImmersionToken _tokenFromSurface(String surface, Map<String, _NhkWord> dict) {
    final dictWord = dict[surface];
    return ImmersionToken(
      surface: surface,
      reading: dictWord?.reading,
      meaningEn: dictWord?.meaningEn,
      meaningVi: null,
    );
  }

  Map<String, _NhkWord> _parseWordList(dynamic raw) {
    final map = <String, _NhkWord>{};
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final surface =
            _string(
              item['word'] ??
                  item['surface'] ??
                  item['text'] ??
                  item['kanji'] ??
                  item['term'],
            ) ??
            '';
        if (surface.trim().isEmpty) continue;
        final reading = _string(
          item['ruby'] ?? item['furigana'] ?? item['reading'] ?? item['kana'],
        );
        final meaning = _string(
          item['meaning'] ??
              item['meaning_en'] ??
              item['definition'] ??
              item['translation'],
        );
        if (reading == null && meaning == null) continue;
        map[surface] = _NhkWord(
          surface: surface,
          reading: reading,
          meaningEn: meaning,
        );
      }
    }
    return map;
  }

  List<Map<String, String>> _extractRssItems(String xmlText) {
    final items = <Map<String, String>>[];
    final itemRegex = RegExp(
      r'<item\b[^>]*>(.*?)</item>',
      caseSensitive: false,
      dotAll: true,
    );
    for (final match in itemRegex.allMatches(xmlText)) {
      final block = match.group(1) ?? '';
      final title = _rssTagValue(block, 'title');
      final link = _rssTagValue(block, 'link');
      final pubDate = _rssTagValue(block, 'pubDate');
      final description = _rssTagValue(block, 'description');
      final encoded = _rssTagValue(block, 'content:encoded');
      items.add({
        if (title != null) 'title': title,
        if (link != null) 'link': link,
        if (pubDate != null) 'pubDate': pubDate,
        if (description != null) 'description': description,
        if (encoded != null) 'content': encoded,
      });
    }
    return items;
  }

  String? _rssTagValue(String source, String tagName) {
    final tag = RegExp.escape(tagName);
    final regex = RegExp(
      '<$tag[^>]*>(.*?)</$tag>',
      caseSensitive: false,
      dotAll: true,
    );
    final match = regex.firstMatch(source);
    if (match == null) return null;
    return _decodeEntities(_unwrapCdata(match.group(1) ?? '').trim());
  }

  String _unwrapCdata(String value) {
    final match = RegExp(
      r'<!\[CDATA\[(.*?)\]\]>',
      dotAll: true,
    ).firstMatch(value.trim());
    return match?.group(1) ?? value;
  }

  String? _extractMatchaArticleId(String link) {
    final match = RegExp(r'/easy/(\d+)(?:[/?#]|$)').firstMatch(link);
    return match?.group(1);
  }

  String? _extractTadokuBookId(String link) {
    final match = RegExp(r'/book/(\d+)(?:[/?#]|$)').firstMatch(link);
    return match?.group(1);
  }

  String? _extractTadokuLevel(String html) {
    final classMatch = RegExp(
      r'class="[^"]*level-l(\d+)[^"]*"',
      caseSensitive: false,
    ).firstMatch(html);
    final level = classMatch?.group(1);
    if (level == null) return null;
    return 'L$level';
  }

  List<List<ImmersionToken>> _extractTadokuParagraphs(String html) {
    final articleMatch = RegExp(
      r'<article[^>]*>(.*?)</article>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    final block = articleMatch?.group(1) ?? html;
    final entryMatch = RegExp(
      r'<div[^>]*class="[^"]*entry-content[^"]*"[^>]*>(.*?)<footer',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(block);
    final section = entryMatch?.group(1) ?? block;
    return _parseHtmlParagraphs(section);
  }

  static const _cacheListKey = 'immersion_cache_list';
  static const _cacheArticlePrefix = 'immersion_cache_article_';

  Future<List<ImmersionArticle>?> _readCacheList({
    bool ignoreTtl = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheListKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(decoded['savedAt']?.toString() ?? '');
      if (!ignoreTtl &&
          (savedAt == null ||
              DateTime.now().difference(savedAt) > _listCacheTtl)) {
        return null;
      }
      final data = decoded['data'] as List<dynamic>? ?? const [];
      return data
          .map((e) => ImmersionArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCacheList(List<ImmersionArticle> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'savedAt': DateTime.now().toIso8601String(),
      'data': articles.map((a) => a.toJson()).toList(),
    };
    await prefs.setString(_cacheListKey, jsonEncode(payload));
  }

  Future<ImmersionArticle?> _readCacheArticle(
    String id, {
    bool ignoreTtl = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cacheArticlePrefix$id');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(decoded['savedAt']?.toString() ?? '');
      if (!ignoreTtl &&
          (savedAt == null ||
              DateTime.now().difference(savedAt) > _articleCacheTtl)) {
        return null;
      }
      final data = decoded['data'] as Map<String, dynamic>;
      return ImmersionArticle.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCacheArticle(ImmersionArticle article) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'savedAt': DateTime.now().toIso8601String(),
      'data': article.toJson(),
    };
    await prefs.setString(
      '$_cacheArticlePrefix${article.id}',
      jsonEncode(payload),
    );
  }

  // --- Read Status Management ---

  static const _readStatusKey = 'immersion_read_ids';
  static const _quizHistoryKey = 'immersion_quiz_history_v1';

  Future<Set<String>> getReadArticleIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readStatusKey) ?? [];
    return list.toSet();
  }

  Future<void> markArticleAsRead(String id, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_readStatusKey) ?? []).toSet();
    if (isRead) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(_readStatusKey, ids.toList());
  }

  Future<List<ImmersionQuizAttempt>> getQuizHistory(
    String articleId, {
    int limit = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizHistoryKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const [];
      final listRaw = decoded[articleId];
      if (listRaw is! List) return const [];
      return listRaw
          .whereType<Map>()
          .map((item) => ImmersionQuizAttempt.fromJson(item))
          .where((attempt) => attempt.total > 0)
          .take(limit)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveQuizAttempt({
    required String articleId,
    required int correct,
    required int total,
    int keep = 20,
  }) async {
    if (total <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizHistoryKey);
    final payload = <String, dynamic>{};
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          payload.addAll(decoded.map((k, v) => MapEntry('$k', v)));
        }
      } catch (_) {
        // Ignore invalid cached payload and recreate.
      }
    }

    final historyRaw = payload[articleId];
    final history = <Map<String, dynamic>>[];
    if (historyRaw is List) {
      for (final entry in historyRaw) {
        if (entry is Map) {
          history.add(entry.map((k, v) => MapEntry('$k', v)));
        }
      }
    }

    history.insert(0, {
      'correct': correct,
      'total': total,
      'attemptedAt': DateTime.now().toIso8601String(),
    });
    if (history.length > keep) {
      history.removeRange(keep, history.length);
    }
    payload[articleId] = history;

    await prefs.setString(_quizHistoryKey, jsonEncode(payload));
  }

  // --- End Read Status Management ---

  String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.trim().isEmpty ? null : text;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    if (RegExp(r'^\d{8}$').hasMatch(trimmed)) {
      final year = int.tryParse(trimmed.substring(0, 4));
      final month = int.tryParse(trimmed.substring(4, 6));
      final day = int.tryParse(trimmed.substring(6, 8));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    var normalized = trimmed.replaceAll('/', '-');
    if (normalized.contains(' ')) {
      normalized = normalized.replaceFirst(' ', 'T');
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$').hasMatch(normalized)) {
      normalized = '$normalized:00';
    }
    return DateTime.tryParse(normalized);
  }

  DateTime? _parseRssDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final match = RegExp(
      r'\b(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})',
    ).firstMatch(raw);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = _monthFromAbbr(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  int? _monthFromAbbr(String abbr) {
    switch (abbr.toLowerCase()) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        return null;
    }
  }

  String _stripTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]+>'), '');
  }

  String _renderRubyText(String html) {
    final rubyRegex = RegExp(r'<ruby[^>]*>(.*?)</ruby>', dotAll: true);
    var output = html;
    for (final match in rubyRegex.allMatches(html)) {
      final ruby = match.group(0) ?? '';
      final token = _tokenFromRuby(ruby, const <String, _NhkWord>{});
      if (token == null) continue;
      final replacement = token.reading == null || token.reading!.isEmpty
          ? token.surface
          : '${token.surface}(${token.reading})';
      output = output.replaceFirst(ruby, replacement);
    }
    return _decodeEntities(_stripTags(output));
  }

  String _decodeEntities(String input) {
    final namedDecoded = input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    final hexDecoded = namedDecoded.replaceAllMapped(
      RegExp(r'&#x([0-9A-Fa-f]+);'),
      (match) {
        final code = int.tryParse(match.group(1)!, radix: 16);
        return code == null ? match.group(0)! : String.fromCharCode(code);
      },
    );
    return hexDecoded.replaceAllMapped(RegExp(r'&#([0-9]+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code == null ? match.group(0)! : String.fromCharCode(code);
    });
  }

  bool _isWhitespace(String char) => char.trim().isEmpty || char == '\u00A0';

  bool _isPunctuation(String char) {
    const punctuation = '。、！？.,!?「」『』（）()[]{}・：:；;…';
    return punctuation.contains(char);
  }
}

class _NhkWord {
  const _NhkWord({required this.surface, this.reading, this.meaningEn});

  final String surface;
  final String? reading;
  final String? meaningEn;
}

class ImmersionQuizAttempt {
  const ImmersionQuizAttempt({
    required this.correct,
    required this.total,
    required this.attemptedAt,
  });

  final int correct;
  final int total;
  final DateTime attemptedAt;

  factory ImmersionQuizAttempt.fromJson(Map<dynamic, dynamic> json) {
    final correct = int.tryParse('${json['correct'] ?? 0}') ?? 0;
    final total = int.tryParse('${json['total'] ?? 0}') ?? 0;
    final attemptedAt =
        DateTime.tryParse('${json['attemptedAt'] ?? ''}') ?? DateTime.now();
    return ImmersionQuizAttempt(
      correct: correct,
      total: total,
      attemptedAt: attemptedAt,
    );
  }
}
