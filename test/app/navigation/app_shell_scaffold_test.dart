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

  test('desktop shell destinations are grouped with upgrade in footer', () {
    expect(navigationGroupForShellBranch(0), NavigationGroup.learning);
    expect(navigationGroupForShellBranch(1), NavigationGroup.learning);
    expect(navigationGroupForShellBranch(2), NavigationGroup.learning);
    expect(navigationGroupForShellBranch(3), NavigationGroup.learning);
    expect(navigationGroupForShellBranch(4), NavigationGroup.progress);
    expect(navigationGroupForShellBranch(5), NavigationGroup.progress);
    expect(navigationGroupForShellBranch(6), NavigationGroup.progress);
    expect(navigationGroupForShellBranch(7), NavigationGroup.other);
    expect(navigationGroupForShellBranch(8), NavigationGroup.other);
    expect(navigationGroupForShellBranch(10), NavigationGroup.other);
    expect(navigationGroupForShellBranch(9), NavigationGroup.footer);
  });

  test('desktop sidebar exposes compact dimensions for grouped layout', () {
    expect(sidebarItemHeightForTesting, 44);
    expect(sidebarFooterItemHeightForTesting, 36);
    expect(sidebarEstimatedContentHeightForTesting, lessThan(600));
  });

  test('shell branch tap uses one navigation mechanism', () {
    final source = File(
      'lib/app/navigation/app_shell_scaffold.dart',
    ).readAsStringSync();
    final goToBranchBody = RegExp(
      r'void _goToBranch[\s\S]*?\n  \}',
    ).firstMatch(source)!.group(0)!;

    expect(goToBranchBody, contains('navigationShell.goBranch'));
    expect(goToBranchBody, isNot(contains('GoRouter.of(context).go')));
  });
}
