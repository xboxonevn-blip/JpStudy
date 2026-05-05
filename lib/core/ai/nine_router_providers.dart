import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/ai/nine_router_client.dart';

final nineRouterConfigProvider = Provider<NineRouterConfig>(
  (_) => NineRouterConfig.fromEnvironment(),
);

final nineRouterClientProvider = Provider<NineRouterClient>(
  (ref) => NineRouterClient(config: ref.watch(nineRouterConfigProvider)),
);
