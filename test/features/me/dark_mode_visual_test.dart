import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';

class _DarkProbe extends StatelessWidget {
  const _DarkProbe();

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return MaterialApp(
      theme: AppTheme.light(AppLanguage.vi),
      darkTheme: AppTheme.dark(AppLanguage.vi),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Card(
          child: Column(
            children: [
              Text('Kho Hán Tự', style: Theme.of(context).textTheme.titleLarge),
              Text(
                'Khám phá và luyện tập',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              FilledButton(onPressed: () {}, child: const Text('Học mới')),
              Chip(
                label: const Text('Mới 185'),
                backgroundColor: palette.outlineSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _contrast(Color a, Color b) {
  final left = a.computeLuminance() + 0.05;
  final right = b.computeLuminance() + 0.05;
  return left > right ? left / right : right / left;
}

void main() {
  testWidgets('dark mode screen probe renders and keeps AA text contrast', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _DarkProbe());
    await tester.pumpAndSettle();

    expect(find.text('Kho Hán Tự'), findsOneWidget);
    expect(find.text('Khám phá và luyện tập'), findsOneWidget);

    final palette = AppThemePalette.dark;
    final pairs = <String, double>{
      'body on bg': _contrast(palette.ink, palette.bg),
      'body on base': _contrast(palette.ink, palette.base),
      'body on surface': _contrast(palette.ink, palette.surface),
      'primary on bg': _contrast(palette.primary, palette.bg),
      'accent on bg': _contrast(palette.accent, palette.bg),
      'success on bg': _contrast(palette.success, palette.bg),
      'warning on bg': _contrast(palette.warning, palette.bg),
      'error on bg': _contrast(palette.error, palette.bg),
    };

    for (final entry in pairs.entries) {
      expect(entry.value, greaterThanOrEqualTo(4.5), reason: entry.key);
    }
  });
}
