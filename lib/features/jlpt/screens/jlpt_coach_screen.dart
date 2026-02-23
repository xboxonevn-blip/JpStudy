import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

import '../models/jlpt_coach_models.dart';
import '../services/jlpt_coach_service.dart';

class JlptCoachScreen extends ConsumerWidget {
  const JlptCoachScreen({super.key});

  String _tr(AppLanguage language, String en, String vi, String ja) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }

  String _areaLabel(AppLanguage language, JlptSkillArea area) {
    switch (area) {
      case JlptSkillArea.vocabulary:
        return _tr(language, 'Vocabulary', 'Tu vung', '??');
      case JlptSkillArea.grammar:
        return _tr(language, 'Grammar', 'Ngu phap', '??');
      case JlptSkillArea.kanji:
        return _tr(language, 'Kanji', 'Kanji', '??');
      case JlptSkillArea.reading:
        return _tr(language, 'Reading', 'Doc hieu', '??');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final snapshotAsync = ref.watch(jlptCoachSnapshotProvider);
    final mistakeRepo = ref.watch(mistakeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr(language, 'JLPT Coach', 'Tro ly JLPT', 'JLPT???')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _FeatureCard(
            icon: Icons.menu_book_rounded,
            title: _tr(
              language,
              '1) Reading comprehension drills',
              '1) Luyen doc hieu',
              '1) ?????',
            ),
            subtitle: _tr(
              language,
              'JLPT-style passages, timer, and answer explanations.',
              'Doan van kieu JLPT, co gio va giai thich dap an.',
              'JLPT????????????????',
            ),
            actionLabel: _tr(language, 'Start reading', 'Bat dau doc', '?????'),
            onTap: () => context.push('/jlpt/reading'),
          ),
          const SizedBox(height: 10),
          _FeatureCard(
            icon: Icons.fact_check_rounded,
            title: _tr(
              language,
              '2) Full-format mock exam',
              '2) Mock exam day du section',
              '2) ???????',
            ),
            subtitle: _tr(
              language,
              'Section timing + per-section score + pass prediction.',
              'Gio tung section + diem tung section + du doan dau.',
              '????????? + ????????? + ?????',
            ),
            actionLabel: _tr(language, 'Start mock', 'Bat dau mock', '?????'),
            onTap: () => context.push('/jlpt/mock-pro'),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE8F8)),
            ),
            child: snapshotAsync.when(
              data: (snapshot) {
                if (snapshot == null) {
                  return Text(
                    _tr(
                      language,
                      '3) Weakness diagnosis + 7-day plan will appear after your first reading/mock attempt.',
                      '3) Chan doan diem yeu + ke hoach 7 ngay se hien sau bai dau tien.',
                      '3) ?????7??????????????????',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  );
                }

                final weakest = snapshot.profile
                    .weakestFirst()
                    .take(3)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        language,
                        '3) Auto weakness diagnosis + 7-day plan',
                        '3) Chan doan diem yeu + ke hoach 7 ngay tu dong',
                        '3) ?????? + 7????',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...weakest.map((stat) {
                      final percent = (stat.accuracy * 100).round();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '${_areaLabel(language, stat.area)}: $percent% (${stat.correct}/${stat.total})',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    ...snapshot.plan.items
                        .take(4)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'D${item.dayOffset + 1} - ${_areaLabel(language, item.area)} - ${item.minutes}m: ${item.action}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(
                _tr(
                  language,
                  'Unable to load diagnosis',
                  'Khong tai duoc chan doan',
                  '??????????',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: mistakeRepo.watchAllMistakes(),
            builder: (context, snapshot) {
              final mistakes = snapshot.data ?? const [];
              final buckets = computeMistakeDueBuckets(
                mistakes,
                DateTime.now(),
              );
              return _FeatureCard(
                icon: Icons.warning_amber_rounded,
                title: _tr(
                  language,
                  '4) Mistake notebook 1-3-7',
                  '4) So tay loi sai 1-3-7',
                  '4) ????? 1-3-7',
                ),
                subtitle: _tr(
                  language,
                  'Due now: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d}',
                  'Den han: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d}',
                  '??: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d}',
                ),
                actionLabel: _tr(
                  language,
                  'Open notebook',
                  'Mo notebook',
                  '??????',
                ),
                onTap: () => context.push('/mistakes'),
              );
            },
          ),
          const SizedBox(height: 10),
          _FeatureCard(
            icon: Icons.speed_rounded,
            title: _tr(
              language,
              '5) Reading speed + context vocab',
              '5) Toc do doc + tu vung theo ngu canh',
              '5) ???? + ????',
            ),
            subtitle: _tr(
              language,
              'Immersion Reader now tracks speed and supports quick-add words to SRS.',
              'Immersion Reader theo doi toc do va cho phep them tu nhanh vao SRS.',
              'Immersion Reader??????SRS??????????????',
            ),
            actionLabel: _tr(
              language,
              'Open immersion',
              'Mo immersion',
              'Immersion???',
            ),
            onTap: () => context.push('/immersion'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF0369A1)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
