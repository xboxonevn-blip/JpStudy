import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';

class VocabItem {
  const VocabItem({
    required this.id,
    required this.term,
    this.reading,
    required this.meaning,
    this.meaningEn,
    this.kanjiMeaning,
    this.mnemonicVi,
    this.mnemonicEn,
    required this.level,
    this.tags,
  });

  final int id;
  final String term;
  final String? reading;
  final String meaning;
  final String? meaningEn;
  final String? kanjiMeaning;
  final String? mnemonicVi;
  final String? mnemonicEn;
  final String level;
  final List<String>? tags;

  bool get hasDisplayReading => shouldShowReading(term: term, reading: reading);

  String displayMeaning(AppLanguage language) {
    final english = meaningEn?.trim() ?? '';
    switch (language) {
      case AppLanguage.vi:
        return meaning;
      case AppLanguage.en:
        return english.isNotEmpty ? english : meaning;
      case AppLanguage.ja:
        return english.isNotEmpty ? english : meaning;
    }
  }

  String? displayMnemonic(AppLanguage language) {
    final vi = mnemonicVi?.trim();
    final en = mnemonicEn?.trim();
    switch (language) {
      case AppLanguage.vi:
        return vi != null && vi.isNotEmpty ? vi : null;
      case AppLanguage.en:
      case AppLanguage.ja:
        return en != null && en.isNotEmpty ? en : null;
    }
  }
}
