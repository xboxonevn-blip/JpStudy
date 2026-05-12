/// Re-exports dart:io for native platforms.
/// On web, the stub (platform_io_web.dart) is used instead.
library;

export 'platform_io_native.dart'
    if (dart.library.js_interop) 'platform_io_web.dart';
