import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop sidebar destinations expose button semantics labels', () {
    final source = File(
      'lib/app/navigation/app_shell_scaffold.dart',
    ).readAsStringSync();

    expect(source, contains('return Semantics('));
    expect(source, contains('label: item.label'));
    expect(source, contains('button: true'));
    expect(source, contains('selected: selected'));
    expect(source, contains('ExcludeSemantics('));
  });
}
