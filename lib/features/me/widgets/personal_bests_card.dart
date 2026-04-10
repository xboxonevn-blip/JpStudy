import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/me/providers/personal_best_provider.dart';

class PersonalBestsCard extends ConsumerWidget {
  const PersonalBestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final bestsAsync = ref.watch(personalBestsProvider);

    return bestsAsync.when(
      data: (bests) {
        if (bests.isEmpty) return const SizedBox.shrink();
        final palette = context.appPalette;
        return AppSectionCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: palette.warning,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _title(language),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...bests
                  .take(5)
                  .map((best) => _BestRow(best: best, language: language)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Personal Bests';
      case AppLanguage.vi:
        return 'Kỷ lục cá nhân';
      case AppLanguage.ja:
        return '自己ベスト';
    }
  }
}

class _BestRow extends StatelessWidget {
  const _BestRow({required this.best, required this.language});

  final PersonalBest best;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final pct = best.bestPercent.round();
    final palette = context.appPalette;
    final percentColor = _percentColor(context, pct);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _modeColor(context, best.mode).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                _modeIcon(best.mode),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_modeLabel(best.mode, language)} · ${best.level}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Text(
                  _attemptsLabel(best.attempts, language),
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.ink.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: percentColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _onAccent(percentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _modeIcon(String mode) {
    switch (mode) {
      case 'learn':
        return '📝';
      case 'test':
        return '🧪';
      case 'flashcard':
        return '🃏';
      default:
        return '📊';
    }
  }

  Color _modeColor(BuildContext context, String mode) {
    final palette = context.appPalette;
    switch (mode) {
      case 'learn':
        return palette.info;
      case 'test':
        return palette.primary;
      case 'flashcard':
        return palette.secondary;
      default:
        return palette.ink.withValues(alpha: 0.52);
    }
  }

  String _modeLabel(String mode, AppLanguage language) {
    switch (mode) {
      case 'learn':
        switch (language) {
          case AppLanguage.en:
            return 'Learn';
          case AppLanguage.vi:
            return 'Học';
          case AppLanguage.ja:
            return '学習';
        }
      case 'test':
        switch (language) {
          case AppLanguage.en:
            return 'Test';
          case AppLanguage.vi:
            return 'Thi thử';
          case AppLanguage.ja:
            return 'テスト';
        }
      case 'flashcard':
        switch (language) {
          case AppLanguage.en:
            return 'Flashcard';
          case AppLanguage.vi:
            return 'Flashcard';
          case AppLanguage.ja:
            return 'フラッシュカード';
        }
      default:
        return mode;
    }
  }

  String _attemptsLabel(int count, AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return '$count attempts';
      case AppLanguage.vi:
        return '$count lần thử';
      case AppLanguage.ja:
        return '$count回';
    }
  }

  Color _percentColor(BuildContext context, int pct) {
    final palette = context.appPalette;
    if (pct >= 90) return palette.success;
    if (pct >= 70) return palette.info;
    if (pct >= 50) return palette.warning;
    return palette.error;
  }

  Color _onAccent(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
