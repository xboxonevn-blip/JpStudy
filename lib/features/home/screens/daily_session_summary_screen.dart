import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/providers/coach_session_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/home/widgets/next_step_suggestions.dart';

class DailySessionSummaryScreen extends ConsumerWidget {
  const DailySessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final progress = ref.watch(dailySessionProgressProvider).valueOrNull;
    final coachPlan = ref.watch(coachSessionPlanProvider);
    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalFix = dashboard?.totalMistakeCount ?? 0;
    final percent = progress?.completionPercent(
          step1Done: totalDue == 0,
          step2Done: totalFix == 0,
        ) ??
        0;

    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _title(language),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: HomeSurface.softPanel(
                  colors: const [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.sessionCompleteTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _summaryLine(language, percent),
                      style: const TextStyle(
                        color: Color(0xFFDBEAFE),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: HomeSurface.softPanel(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _improvedTitle(language),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SummaryItem(label: coachPlan.step1.target),
                    _SummaryItem(label: coachPlan.step2.target),
                    _SummaryItem(label: coachPlan.step3.target),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: HomeSurface.softPanel(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nextTitle(language),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nextLine(language, totalDue, totalFix),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: HomeSurface.softPanel(),
                padding: const EdgeInsets.all(16),
                child: const NextStepSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'Daily Coach Summary';
      case AppLanguage.vi:
        return 'Tổng kết Daily Coach';
    }
  }

  String _summaryLine(AppLanguage language, int percent) {
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'You closed $percent% of today\'s guided session.';
      case AppLanguage.vi:
        return 'Bạn đã hoàn thành $percent% lộ trình hôm nay.';
    }
  }

  String _improvedTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'What improved today';
      case AppLanguage.vi:
        return 'Điều đã cải thiện hôm nay';
    }
  }

  String _nextTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'Tomorrow cue';
      case AppLanguage.vi:
        return 'Gợi ý cho ngày mai';
    }
  }

  String _nextLine(AppLanguage language, int totalDue, int totalFix) {
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        if (totalDue == 0 && totalFix == 0) {
          return 'Queue is clear. Tomorrow can start with a deeper lesson or immersion pass.';
        }
        return 'Some items are still waiting. Start tomorrow by clearing due reviews, then clean up weak spots.';
      case AppLanguage.vi:
        if (totalDue == 0 && totalFix == 0) {
          return 'Hàng đợi đã sạch. Ngày mai có thể bắt đầu bằng bài mới hoặc immersion sâu hơn.';
        }
        return 'Vẫn còn mục chưa xử lý. Ngày mai hãy dọn review đến hạn trước, rồi xử lý điểm yếu.';
    }
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
