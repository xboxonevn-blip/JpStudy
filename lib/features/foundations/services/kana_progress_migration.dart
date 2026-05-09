import 'package:jpstudy/data/daos/kana_srs_dao.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/services/foundations_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const foundationsKanaMigratedPrefsKey = 'foundations.kana.migrated';

class KanaProgressMigration {
  KanaProgressMigration({
    required this.dao,
    required this.preferences,
    FoundationsContentService? contentService,
  }) : contentService = contentService ?? FoundationsContentService();

  final KanaSrsDao dao;
  final SharedPreferences preferences;
  final FoundationsContentService contentService;

  Future<void> runIfNeeded() async {
    if (preferences.getBool(foundationsKanaMigratedPrefsKey) ?? false) return;

    final studied =
        preferences.getStringList(foundationsStudiedPrefsKey) ?? const [];
    if (studied.isEmpty) {
      await preferences.setBool(foundationsKanaMigratedPrefsKey, true);
      return;
    }

    final chart = await contentService.loadKanaChart();
    final scriptByKana = _scriptMap(chart);
    final now = DateTime.now();
    for (final kana in studied.toSet()) {
      await dao.upsertReview(
        kana: kana,
        script: scriptByKana[kana] ?? 'hiragana',
        stability: 10,
        difficulty: 3,
        reps: 1,
        lapses: 0,
        dueAt: now,
        lastReviewedAt: now,
      );
    }
    await preferences.setBool(foundationsKanaMigratedPrefsKey, true);
  }

  Map<String, String> _scriptMap(KanaChart chart) {
    return {
      for (final entry in chart.hiragana.entries) entry.kana: 'hiragana',
      for (final entry in chart.katakana.entries) entry.kana: 'katakana',
      for (final entry in chart.hiragana.compounds)
        entry.kana: 'compound_hiragana',
      for (final entry in chart.katakana.compounds)
        entry.kana: 'compound_katakana',
    };
  }
}
