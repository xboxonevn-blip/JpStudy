import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NineRouterConfig {
  const NineRouterConfig({
    required this.baseUrl,
    this.apiKey,
    this.defaultChatModel = 'openai/gpt-4o-mini',
    this.defaultImageModel,
    this.defaultTtsModel,
    this.defaultSttModel,
    this.defaultEmbeddingModel,
    this.defaultWebSearchModel,
    this.defaultWebFetchModel = 'fetch-combo',
  });

  factory NineRouterConfig.fromEnvironment() => const NineRouterConfig(
    baseUrl: String.fromEnvironment('NINEROUTER_URL'),
    apiKey: String.fromEnvironment('NINEROUTER_KEY'),
    defaultChatModel: String.fromEnvironment(
      'NINEROUTER_CHAT_MODEL',
      defaultValue: 'openai/gpt-4o-mini',
    ),
    defaultImageModel: String.fromEnvironment('NINEROUTER_IMAGE_MODEL'),
    defaultTtsModel: String.fromEnvironment('NINEROUTER_TTS_MODEL'),
    defaultSttModel: String.fromEnvironment('NINEROUTER_STT_MODEL'),
    defaultEmbeddingModel: String.fromEnvironment('NINEROUTER_EMBEDDING_MODEL'),
    defaultWebSearchModel: String.fromEnvironment(
      'NINEROUTER_WEB_SEARCH_MODEL',
    ),
    defaultWebFetchModel: String.fromEnvironment(
      'NINEROUTER_WEB_FETCH_MODEL',
      defaultValue: 'fetch-combo',
    ),
  );

  final String baseUrl;
  final String? apiKey;
  final String defaultChatModel;
  final String? defaultImageModel;
  final String? defaultTtsModel;
  final String? defaultSttModel;
  final String? defaultEmbeddingModel;
  final String? defaultWebSearchModel;
  final String defaultWebFetchModel;

  bool get isEnabled => baseUrl.trim().isNotEmpty;

  Uri endpoint(String path) {
    if (!isEnabled) {
      throw const NineRouterException('9Router is not configured');
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}

class NineRouterClient {
  NineRouterClient({
    NineRouterConfig? config,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
  }) : config = config ?? NineRouterConfig.fromEnvironment(),
       _httpClient = httpClient ?? http.Client();

  final NineRouterConfig config;
  final Duration timeout;
  final http.Client _httpClient;

  Future<NineRouterHealth> health() async {
    final json = await _getJson('/api/health');
    return NineRouterHealth.fromJson(json);
  }

  Future<List<NineRouterModel>> models([String path = '/v1/models']) async {
    final json = await _getJson(path);
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, Object?>>()
        .map(NineRouterModel.fromJson)
        .toList(growable: false);
  }

  Future<String> chat({
    required List<NineRouterChatMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    final json = await _postJson('/v1/chat/completions', {
      'model': model ?? config.defaultChatModel,
      'messages': messages.map((message) => message.toJson()).toList(),
      'temperature': ?temperature,
      'max_tokens': ?maxTokens,
    });
    final choices = json['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map<String, Object?>) {
        final message = first['message'];
        if (message is Map<String, Object?>) {
          return (message['content'] as String?) ?? '';
        }
      }
    }
    return '';
  }

  Future<List<double>> embedding({
    required String input,
    String? model,
    int? dimensions,
  }) async {
    final embeddingModel = model ?? config.defaultEmbeddingModel;
    if (embeddingModel == null || embeddingModel.isEmpty) {
      throw const NineRouterException(
        '9Router embedding model is not configured',
      );
    }
    final json = await _postJson('/v1/embeddings', {
      'model': embeddingModel,
      'input': input,
      'dimensions': ?dimensions,
    });
    final data = json['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, Object?> && first['embedding'] is List) {
        return (first['embedding'] as List)
            .whereType<num>()
            .map((value) => value.toDouble())
            .toList(growable: false);
      }
    }
    return const [];
  }

  Future<List<NineRouterSearchResult>> search({
    required String query,
    String? model,
    String? provider,
    int? maxResults,
    String? language,
    String? country,
    String? timeRange,
  }) async {
    final selectedModel = model ?? config.defaultWebSearchModel;
    if ((selectedModel == null || selectedModel.isEmpty) &&
        (provider == null || provider.isEmpty)) {
      throw const NineRouterException(
        '9Router web search model is not configured',
      );
    }
    final json = await _postJson('/v1/search', {
      if (selectedModel != null && selectedModel.isNotEmpty)
        'model': selectedModel,
      if (provider != null && provider.isNotEmpty) 'provider': provider,
      'query': query,
      'max_results': ?maxResults,
      'language': ?language,
      'country': ?country,
      'time_range': ?timeRange,
    });
    final results = json['results'] ?? json['data'];
    if (results is! List) return const [];
    return results
        .whereType<Map<String, Object?>>()
        .map(NineRouterSearchResult.fromJson)
        .toList(growable: false);
  }

  Future<String> fetchUrl({
    required String url,
    String? model,
    String format = 'markdown',
    int? maxCharacters,
  }) async {
    final json = await _postJson('/v1/web/fetch', {
      'model': model ?? config.defaultWebFetchModel,
      'url': url,
      'format': format,
      'max_characters': ?maxCharacters,
    });
    return (json['content'] ?? json['text'] ?? json['markdown'] ?? '')
        .toString();
  }

  Future<Map<String, Object?>> _getJson(String path) async {
    final response = await _httpClient
        .get(config.endpoint(path), headers: _headers())
        .timeout(timeout);
    return _decodeResponse(response);
  }

  Future<Map<String, Object?>> _postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _httpClient
        .post(
          config.endpoint(path),
          headers: _headers(contentType: 'application/json'),
          body: jsonEncode(body),
        )
        .timeout(timeout);
    return _decodeResponse(response);
  }

  Map<String, String> _headers({String? contentType}) => {
    'Content-Type': ?contentType,
    if ((config.apiKey ?? '').isNotEmpty)
      'Authorization': 'Bearer ${config.apiKey}',
  };

  Map<String, Object?> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NineRouterException(
        '9Router request failed (${response.statusCode})',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) return decoded;
    throw const NineRouterException('9Router returned an invalid JSON object');
  }
}

class NineRouterChatMessage {
  const NineRouterChatMessage({required this.role, required this.content});

  const NineRouterChatMessage.system(String content)
    : this(role: 'system', content: content);

  const NineRouterChatMessage.user(String content)
    : this(role: 'user', content: content);

  const NineRouterChatMessage.assistant(String content)
    : this(role: 'assistant', content: content);

  final String role;
  final String content;

  Map<String, Object?> toJson() => {'role': role, 'content': content};
}

class NineRouterHealth {
  const NineRouterHealth({required this.status, this.details});

  factory NineRouterHealth.fromJson(Map<String, Object?> json) =>
      NineRouterHealth(
        status: (json['status'] ?? json['ok'] ?? 'unknown').toString(),
        details: json,
      );

  final String status;
  final Map<String, Object?>? details;
}

class NineRouterModel {
  const NineRouterModel({required this.id, this.kind, this.name});

  factory NineRouterModel.fromJson(Map<String, Object?> json) =>
      NineRouterModel(
        id: (json['id'] ?? '').toString(),
        kind: json['kind']?.toString(),
        name: json['name']?.toString(),
      );

  final String id;
  final String? kind;
  final String? name;
}

class NineRouterSearchResult {
  const NineRouterSearchResult({
    required this.title,
    required this.url,
    this.snippet,
  });

  factory NineRouterSearchResult.fromJson(Map<String, Object?> json) =>
      NineRouterSearchResult(
        title: (json['title'] ?? json['name'] ?? '').toString(),
        url: (json['url'] ?? json['link'] ?? '').toString(),
        snippet: (json['snippet'] ?? json['content'] ?? json['text'])
            ?.toString(),
      );

  final String title;
  final String url;
  final String? snippet;
}

class NineRouterException implements Exception {
  const NineRouterException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => statusCode == null
      ? 'NineRouterException: $message'
      : 'NineRouterException: $message\n$body';
}
