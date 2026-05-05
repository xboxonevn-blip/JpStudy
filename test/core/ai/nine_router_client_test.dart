import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jpstudy/core/ai/nine_router_client.dart';

void main() {
  const config = NineRouterConfig(
    baseUrl: 'https://router.test',
    apiKey: 'secret',
    defaultEmbeddingModel: 'embed-model',
    defaultWebSearchModel: 'tavily/search',
  );

  test('chat posts OpenAI-compatible payload', () async {
    late http.Request captured;
    final client = NineRouterClient(
      config: config,
      httpClient: MockClient((request) async {
        captured = request;
        expect(
          request.url.toString(),
          'https://router.test/v1/chat/completions',
        );
        expect(request.headers['Authorization'], 'Bearer secret');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['model'], 'openai/gpt-4o-mini');
        expect(body['messages'], isA<List>());
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': '???????'},
              },
            ],
          }),
          200,
        );
      }),
    );

    final response = await client.chat(
      messages: const [NineRouterChatMessage.user('Plan my JLPT study')],
    );

    expect(captured.method, 'POST');
    expect(response, '???????');
  });

  test('embedding parses vectors', () async {
    final client = NineRouterClient(
      config: config,
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['model'], 'embed-model');
        expect(body['input'], '???');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'embedding': [0, 1.5, -2],
              },
            ],
          }),
          200,
        );
      }),
    );

    expect(await client.embedding(input: '???'), [0.0, 1.5, -2.0]);
  });

  test('non-success response throws typed exception', () async {
    final client = NineRouterClient(
      config: config,
      httpClient: MockClient((_) async => http.Response('nope', 401)),
    );

    expect(
      () => client.health(),
      throwsA(
        isA<NineRouterException>().having(
          (e) => e.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });
}
