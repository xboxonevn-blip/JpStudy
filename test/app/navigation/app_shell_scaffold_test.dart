import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/core/study_level.dart';

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

  test('N5 shell destinations include Kana branch', () {
    expect(visibleShellBranchIndicesForLevel(StudyLevel.n5), [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
    ]);
    expect(bottomShellBranchIndicesForLevel(StudyLevel.n5), [4, 1, 0, 7]);
  });

  test('N4+ shell destinations hide Kana branch', () {
    for (final level in [
      StudyLevel.n4,
      StudyLevel.n3,
      StudyLevel.n2,
      StudyLevel.n1,
    ]) {
      final visible = visibleShellBranchIndicesForLevel(level);
      expect(visible, hasLength(10));
      expect(visible, isNot(contains(1)));
      expect(bottomShellBranchIndicesForLevel(level), [4, 0, 7]);
    }
  });
}
