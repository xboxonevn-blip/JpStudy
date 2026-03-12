import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/widgets/discover_practice_panel.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HomeSurface.pageHorizontalPadding,
              16,
              HomeSurface.pageHorizontalPadding,
              96,
            ),
            children: [
              _IntroPanel(
                title: _title(language),
                subtitle: _subtitle(language),
                ctaLabel: _searchLabel(language),
                onTap: () => context.push('/search'),
              ),
              const SizedBox(height: 16),
              const DiscoverPracticePanel(initiallyExpanded: true),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Luyen tap';
      case AppLanguage.ja:
        return 'Practice';
    }
  }

  String _subtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'One place for review, drills, exam prep, and skill training.';
      case AppLanguage.vi:
        return 'Mot noi de on tap, luyen bai, thi thu va ren ky nang.';
      case AppLanguage.ja:
        return 'Review, drills, exam prep, and skill training in one place.';
    }
  }

  String _searchLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Search';
      case AppLanguage.vi:
        return 'Tim kiem';
      case AppLanguage.ja:
        return 'Search';
    }
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(
        colors: const [Color(0xFFF8FCFF), Color(0xFFFFF7ED)],
        radius: 28,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.search_rounded),
            label: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}
