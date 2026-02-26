import 'package:flutter/material.dart';
import 'app_language.dart';

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
        return 'Luyện thi JLPT';
      case StudyGoal.reading:
        return 'Đọc tiếng Nhật';
      case StudyGoal.writing:
        return 'Luyện viết';
    }
  }

  String get _labelJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'JLPT試験対策';
      case StudyGoal.reading:
        return '日本語の読み取り';
      case StudyGoal.writing:
        return '書き練習';
    }
  }

  String get _descEn {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Prepare for N5, N4, N3 exams';
      case StudyGoal.reading:
        return 'Manga, news, books';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descVi {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Chuẩn bị kỳ thi N5, N4, N3';
      case StudyGoal.reading:
        return 'Manga, tin tức, sách';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'N5、N4、N3試験に備える';
      case StudyGoal.reading:
        return 'マンガ、ニュース、本';
      case StudyGoal.writing:
        return 'ひらがな、カタカナ、漢字';
    }
  }
}
