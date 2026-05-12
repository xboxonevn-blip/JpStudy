import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('google_fonts dependency is not used for web font loading', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final theme = File('lib/app/theme/app_theme.dart').readAsStringSync();

    expect(pubspec, isNot(contains('google_fonts:')));
    expect(theme, isNot(contains('GoogleFonts')));
  });
}
