import 'package:jpstudy/core/app_language.dart';

enum StudyLevel {
  n5('N5'),
  n4('N4'),
  n3('N3'),
  n2('N2'),
  n1('N1');

  final String shortLabel;
  const StudyLevel(this.shortLabel);

  /// Returns the [StudyLevel] whose [shortLabel] matches [code] (case-insensitive).
  /// Returns `null` for unrecognised codes (e.g. SE).
  static StudyLevel? fromCode(String code) =>
      switch (code.trim().toUpperCase()) {
        'N5' => StudyLevel.n5,
        'N4' => StudyLevel.n4,
        'N3' => StudyLevel.n3,
        'N2' => StudyLevel.n2,
        'N1' => StudyLevel.n1,
        _ => null,
      };

  String description(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return _descriptionEn;
      case AppLanguage.vi:
        return _descriptionVi;
      case AppLanguage.ja:
        return _descriptionJa;
    }
  }

  String get _descriptionEn {
    switch (this) {
      case StudyLevel.n5:
        return 'Beginner fundamentals';
      case StudyLevel.n4:
        return 'Lower intermediate';
      case StudyLevel.n3:
        return 'Intermediate';
      case StudyLevel.n2:
        return 'Upper intermediate';
      case StudyLevel.n1:
        return 'Advanced';
    }
  }

  String get _descriptionVi {
    switch (this) {
      case StudyLevel.n5:
        return 'Nhập môn căn bản';
      case StudyLevel.n4:
        return 'Sơ trung cấp';
      case StudyLevel.n3:
        return 'Trung cấp';
      case StudyLevel.n2:
        return 'Trung cao cấp';
      case StudyLevel.n1:
        return 'Cao cấp';
    }
  }

  String get _descriptionJa {
    switch (this) {
      case StudyLevel.n5:
        return '入門基礎';
      case StudyLevel.n4:
        return '初中級';
      case StudyLevel.n3:
        return '中級';
      case StudyLevel.n2:
        return '上中級';
      case StudyLevel.n1:
        return '上級';
    }
  }
}
