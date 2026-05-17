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

  test('N5 shell destinations use five primary branches', () {
    expect(visibleShellBranchIndicesForLevel(StudyLevel.n5), [0, 1, 2, 3, 4]);
    expect(bottomShellBranchIndicesForLevel(StudyLevel.n5), [0, 1, 2, 3, 4]);
  });

  test('N4+ shell destinations use the same five primary branches', () {
    for (final level in [
      StudyLevel.n4,
      StudyLevel.n3,
      StudyLevel.n2,
      StudyLevel.n1,
    ]) {
      final visible = visibleShellBranchIndicesForLevel(level);
      expect(visible, [0, 1, 2, 3, 4]);
      expect(bottomShellBranchIndicesForLevel(level), [0, 1, 2, 3, 4]);
    }
  });

  test(
    'desktop shell destinations are grouped without product-sprawl branches',
    () {
      expect(navigationGroupForShellBranch(0), NavigationGroup.learning);
      expect(navigationGroupForShellBranch(1), NavigationGroup.learning);
      expect(navigationGroupForShellBranch(2), NavigationGroup.progress);
      expect(navigationGroupForShellBranch(3), NavigationGroup.other);
      expect(navigationGroupForShellBranch(4), NavigationGroup.other);
    },
  );

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
