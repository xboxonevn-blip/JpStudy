import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  AppLanguage? _selectedLanguage;
  bool _isSaving = false;

  Future<void> _continue() async {
    final selected = _selectedLanguage;
    if (selected == null || _isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    final returnTarget = _returnTarget();

    await ref.read(appLanguageProvider.notifier).setLanguage(selected);
    if (!mounted) {
      return;
    }

    if (selected == AppLanguage.ja) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefOnboardingLevel, StudyLevel.n3.name);
      await prefs.setBool(prefOnboardingCompleted, true);
      ref.read(studyLevelProvider.notifier).state = StudyLevel.n3;
      ref.read(onboardingDoneProvider.notifier).state = true;
      if (!mounted) {
        return;
      }
      context.go(returnTarget);
      return;
    }

    final levelUri = Uri(
      path: AppRoutePath.onboardingLevel,
      queryParameters: returnTarget == AppRoutePath.home
          ? null
          : {'from': returnTarget},
    );
    context.go(levelUri.toString());
  }

  String _returnTarget() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from == null ||
        from.isEmpty ||
        from == AppRoutePath.onboardingLanguage ||
        from == AppRoutePath.onboardingLevel) {
      return AppRoutePath.home;
    }
    return from;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;

    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      language.chooseLanguageTitle,
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      language.onboardingChooseLanguageSubtitle,
                      style: TextStyle(
                        color: palette.ink.withValues(alpha: 0.62),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (final option in AppLanguage.values)
                      _LanguageOptionTile(
                        language: option,
                        selected: _selectedLanguage == option,
                        onTap: () => setState(() => _selectedLanguage = option),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      key: const ValueKey('language_continue'),
                      onPressed: _selectedLanguage == null || _isSaving
                          ? null
                          : _continue,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: palette.outline,
                        disabledForegroundColor: palette.ink.withValues(
                          alpha: 0.45,
                        ),
                      ),
                      child: Text(language.languageContinueAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected
                ? palette.primary.withValues(alpha: 0.08)
                : palette.elevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? palette.primary : palette.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette.primary.withValues(alpha: 0.12),
                child: Text(
                  language.shortCode,
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  language.label,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: palette.primary),
            ],
          ),
        ),
      ),
    );
  }
}
