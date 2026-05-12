import 'dart:js_interop';

import 'package:web/web.dart' as web;

extension type _NavigatorDnt(JSObject _) implements JSObject {
  external String? get doNotTrack;
}

bool isDoNotTrackEnabled() {
  final value = _NavigatorDnt(web.window.navigator).doNotTrack;
  return value == '1' || value?.toLowerCase() == 'yes';
}
