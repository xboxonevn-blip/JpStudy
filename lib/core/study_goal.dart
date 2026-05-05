import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';

enum StudyGoal { jlpt, reading, writing }

extension StudyGoalExtension on StudyGoal {
  String label(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return _labelEn;
      case AppLanguage.vi:
        return _labelVi;
      case AppLanguage.ja:
        return _labelJa;
    }
  }

  String description(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return _descEn;
      case AppLanguage.vi:
        return _descVi;
      case AppLanguage.ja:
        return _descJa;
    }
  }

  IconData get icon {
    switch (this) {
      case StudyGoal.jlpt:
        return Icons.assignment_outlined;
      case StudyGoal.reading:
        return Icons.menu_book_outlined;
      case StudyGoal.writing:
        return Icons.edit_outlined;
    }
  }

  String get _labelEn {
    switch (this) {
      case StudyGoal.jlpt:
        return 'JLPT Exam Prep';
      case StudyGoal.reading:
        return 'Read Japanese';
      case StudyGoal.writing:
        return 'Practice Writing';
    }
  }

  String get _labelVi {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Luy?n thi JLPT';
      case StudyGoal.reading:
        return '??c ti?ng Nh?t';
      case StudyGoal.writing:
        return 'Luy?n vi?t';
    }
  }

  String get _labelJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'JLPT????';
      case StudyGoal.reading:
        return '????????';
      case StudyGoal.writing:
        return '????';
    }
  }

  String get _descEn {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Prepare for N5, N4, N3, N2, N1 exams';
      case StudyGoal.reading:
        return 'Manga, news, books';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descVi {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Chu?n b? k? thi N5, N4, N3, N2, N1';
      case StudyGoal.reading:
        return 'Manga, tin t?c, s?ch';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'N5?N4?N3?N2?N1??????';
      case StudyGoal.reading:
        return '??????????';
      case StudyGoal.writing:
        return '????????????';
    }
  }
}
