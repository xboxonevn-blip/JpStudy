import 'dart:async';

import 'package:web/web.dart' as web;

const _liveRegionId = 'jpstudy-aria-live';

void announcePolite(String message) {
  final region = _ensureLiveRegion();
  region.textContent = '';
  Timer(const Duration(milliseconds: 50), () {
    region.textContent = message;
  });
}

web.Element _ensureLiveRegion() {
  final existing = web.document.getElementById(_liveRegionId);
  if (existing != null) return existing;
  final region = web.document.createElement('div');
  region.id = _liveRegionId;
  region.setAttribute('aria-live', 'polite');
  region.setAttribute('aria-atomic', 'true');
  region.setAttribute(
    'style',
    'position:absolute;width:1px;height:1px;margin:-1px;border:0;padding:0;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap;',
  );
  web.document.body?.append(region);
  return region;
}
