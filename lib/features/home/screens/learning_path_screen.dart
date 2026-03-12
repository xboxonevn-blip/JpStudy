import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';
import 'package:jpstudy/features/home/widgets/mini_dashboard.dart';
import 'package:jpstudy/features/home/widgets/weakness_radar_card.dart';
import 'package:jpstudy/features/home/widgets/weekly_challenge_card.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JapaneseBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 68),
          child: CustomScrollView(
            slivers: const [
              SliverToBoxAdapter(child: DailySessionCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: WeeklyChallengeCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: WeaknessRadarCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                  child: MiniDashboard(),
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
