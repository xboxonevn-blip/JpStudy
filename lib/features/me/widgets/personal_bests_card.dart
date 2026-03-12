import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFBBF24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _title(language),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...bests.take(5).map(
                    (best) => _BestRow(best: best, language: language),
                  ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _modeColor(best.mode).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _modeIcon(best.mode),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_modeLabel(best.mode, language)} · ${best.level}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _attemptsLabel(best.attempts, language),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF78716C),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _percentColor(pct),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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

  Color _modeColor(String mode) {
    switch (mode) {
      case 'learn':
        return Colors.blue;
      case 'test':
        return Colors.purple;
      case 'flashcard':
        return Colors.teal;
      default:
        return Colors.grey;
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

  Color _percentColor(int pct) {
    if (pct >= 90) return const Color(0xFF16A34A);
    if (pct >= 70) return const Color(0xFF2563EB);
    if (pct >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}
