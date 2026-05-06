import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';

final coachSessionPlanProvider = Provider<CoachSessionPlan>((ref) {
  final d = ref.watch(
    dashboardProvider.select((v) {
      final s = v.value;
      return (
        vocabDue: s?.vocabDue ?? 0,
        grammarDue: s?.grammarDue ?? 0,
        kanjiDue: s?.kanjiDue ?? 0,
        totalMistakeCount: s?.totalMistakeCount ?? 0,
        vocabMistakeCount: s?.vocabMistakeCount ?? 0,
        grammarMistakeCount: s?.grammarMistakeCount ?? 0,
        kanjiMistakeCount: s?.kanjiMistakeCount ?? 0,
      );
    }),
  );
  final language = ref.watch(appLanguageProvider);
  final continueAction = ref.watch(continueActionProvider).value;
  final recoveryPack = ref.watch(recoveryPackProvider).value;
  final grammarGhostCount = ref
      .watch(grammarGhostCountProvider)
      .maybeWhen(data: (count) => count, orElse: () => 0);
  final vocabGhostCount = ref
      .watch(vocabGhostCountProvider)
      .maybeWhen(data: (count) => count, orElse: () => 0);

  final totalDue = d.vocabDue + d.grammarDue + d.kanjiDue;
  final ghostCount = grammarGhostCount + vocabGhostCount;
  final totalFix = d.totalMistakeCount + ghostCount;

  return CoachSessionPlan(
    step1: _buildStep1(
      language: language,
      vocabDue: d.vocabDue,
      grammarDue: d.grammarDue,
      kanjiDue: d.kanjiDue,
      totalDue: totalDue,
    ),
    step2: _buildStep2(
      language: language,
      grammarGhostCount: grammarGhostCount,
      vocabGhostCount: vocabGhostCount,
      vocabMistakeCount: d.vocabMistakeCount,
      grammarMistakeCount: d.grammarMistakeCount,
      kanjiMistakeCount: d.kanjiMistakeCount,
      totalFix: totalFix,
    ),
    step3: _buildStep3(
      language: language,
      continueAction: continueAction,
      recoveryPack: recoveryPack,
    ),
  );
});

CoachStep _buildStep1({
  required AppLanguage language,
  required int vocabDue,
  required int grammarDue,
  required int kanjiDue,
  required int totalDue,
}) {
  if (totalDue == 0) {
    return CoachStep(
      target: _l(language, en: 'All reviews cleared', vi: 'Đã ôn xong tất cả'),
      detail: null,
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF16A34A),
    );
  }

  final parts = <String>[];
  if (vocabDue > 0) {
    parts.add(_l(language, en: '$vocabDue vocab', vi: '$vocabDue từ vựng'));
  }
  if (grammarDue > 0) {
    parts.add(_l(language, en: '$grammarDue grammar', vi: '$grammarDue ngữ pháp'));
  }
  if (kanjiDue > 0) {
    parts.add('$kanjiDue kanji');
  }
  final breakdown = parts.join(' · ');

  return CoachStep(
    target: _l(
      language,
      en: 'Review $totalDue due items',
      vi: 'Ôn $totalDue mục đến hạn',
    ),
    detail: breakdown,
    icon: Icons.schedule_rounded,
    color: const Color(0xFF2563EB),
  );
}

CoachStep _buildStep2({
  required AppLanguage language,
  required int grammarGhostCount,
  required int vocabGhostCount,
  required int vocabMistakeCount,
  required int grammarMistakeCount,
  required int kanjiMistakeCount,
  required int totalFix,
}) {
  if (totalFix == 0) {
    return CoachStep(
      target: _l(language, en: 'No weak spots left', vi: 'Không còn điểm yếu'),
      detail: null,
      icon: Icons.verified_outlined,
      color: const Color(0xFF16A34A),
    );
  }

  final parts = <String>[];
  final grammarTotal = grammarGhostCount + grammarMistakeCount;
  final vocabTotal = vocabGhostCount + vocabMistakeCount;
  if (grammarTotal > 0) {
    parts.add(_l(
      language,
      en: '$grammarTotal grammar ghosts',
      vi: '$grammarTotal lỗi ngữ pháp',
    ));
  }
  if (vocabTotal > 0) {
    parts.add(_l(
      language,
      en: '$vocabTotal vocab mistakes',
      vi: '$vocabTotal lỗi từ vựng',
    ));
  }
  if (kanjiMistakeCount > 0) {
    parts.add(_l(
      language,
      en: '$kanjiMistakeCount kanji misses',
      vi: '$kanjiMistakeCount lỗi kanji',
    ));
  }
  final breakdown = parts.join(' · ');

  return CoachStep(
    target: _l(
      language,
      en: 'Fix $totalFix weak spots',
      vi: 'Sửa $totalFix điểm yếu',
    ),
    detail: breakdown,
    icon: Icons.healing_rounded,
    color: const Color(0xFFDC2626),
  );
}

CoachStep _buildStep3({
  required AppLanguage language,
  required ContinueAction? continueAction,
  required RecoveryPack? recoveryPack,
}) {
  if (recoveryPack != null) {
    return CoachStep(
      target: _l(
        language,
        en: 'Recovery pack: ${recoveryPack.lessonTitle}',
        vi: 'Gói phục hồi: ${recoveryPack.lessonTitle}',
      ),
      detail: _l(
        language,
        en: '${recoveryPack.itemCount} items to reinforce',
        vi: '${recoveryPack.itemCount} mục cần củng cố',
      ),
      icon: Icons.medical_services_outlined,
      color: const Color(0xFF2563EB),
    );
  }

  if (continueAction?.type == ContinueActionType.nextLesson &&
      continueAction?.data is int) {
    return CoachStep(
      target: _l(
        language,
        en: 'Push forward: ${continueAction!.label}',
        vi: 'Tiến tiếp: ${continueAction.label}',
      ),
      detail: _l(
        language,
        en: 'Start new material while momentum is high',
        vi: 'Bắt đầu bài mới khi đà học còn mạnh',
      ),
      icon: Icons.play_lesson_rounded,
      color: const Color(0xFF16A34A),
    );
  }

  return CoachStep(
    target: _l(
      language,
      en: 'Read an immersion article',
      vi: 'Đọc một bài đắm mình',
    ),
    detail: _l(
      language,
      en: 'Save unknown words to grow your SRS queue',
      vi: 'Lưu từ lạ để thêm vào hàng đợi SRS',
    ),
    icon: Icons.article_rounded,
    color: const Color(0xFF059669),
  );
}

String _l(AppLanguage language, {required String en, required String vi}) {
  switch (language) {
    case AppLanguage.en:
    case AppLanguage.ja:
      return en;
    case AppLanguage.vi:
      return vi;
  }
}

class CoachSessionPlan {
  const CoachSessionPlan({
    required this.step1,
    required this.step2,
    required this.step3,
  });

  final CoachStep step1;
  final CoachStep step2;
  final CoachStep step3;

  List<CoachStep> get steps => [step1, step2, step3];
}

class CoachStep {
  const CoachStep({
    required this.target,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String target;
  final String? detail;
  final IconData icon;
  final Color color;
}


