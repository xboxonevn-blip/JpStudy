import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

class LibraryRoadmapBoard {
  const LibraryRoadmapBoard({
    required this.headline,
    required this.caption,
    required this.primaryAction,
    required this.quickActions,
    required this.stats,
  });

  final String headline;
  final String caption;
  final LibraryRoadmapAction primaryAction;
  final List<LibraryRoadmapAction> quickActions;
  final List<LibraryRoadmapStat> stats;
}

class LibraryRoadmapAction {
  const LibraryRoadmapAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.route,
    required this.icon,
    required this.color,
    this.badge,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String route;
  final IconData icon;
  final Color color;
  final String? badge;
}

class LibraryRoadmapStat {
  const LibraryRoadmapStat({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
}

LibraryRoadmapBoard buildLibraryRoadmapBoard({
  required AppLanguage language,
  required StudyLevel level,
  required List<LessonMeta> lessons,
  required int fallbackLessonId,
}) {
  final totalLessons = lessons.length;
  final totalTerms = lessons.fold<int>(
    0,
    (sum, lesson) => sum + lesson.termCount,
  );
  final completedTerms = lessons.fold<int>(
    0,
    (sum, lesson) => sum + lesson.completedCount.clamp(0, lesson.termCount),
  );
  final completionRate = totalTerms == 0
      ? 0
      : ((completedTerms / totalTerms) * 100).round();

  final sortedDue =
      lessons.where((lesson) => lesson.dueCount > 0).toList(growable: false)
        ..sort((left, right) {
          final byDue = right.dueCount.compareTo(left.dueCount);
          if (byDue != 0) {
            return byDue;
          }
          return left.id.compareTo(right.id);
        });

  final inProgress = lessons
      .where(
        (lesson) =>
            lesson.completedCount > 0 &&
            lesson.completedCount < lesson.termCount,
      )
      .toList(growable: false);
  final nextLesson = lessons.firstWhere(
    (lesson) => lesson.completedCount < lesson.termCount,
    orElse: () => LessonMeta(
      id: fallbackLessonId,
      level: level.shortLabel,
      title: _fallbackLessonTitle(language, fallbackLessonId),
      isCustomTitle: false,
      tags: '',
      termCount: 0,
      completedCount: 0,
      dueCount: 0,
      updatedAt: null,
    ),
  );

  final primaryAction = sortedDue.isNotEmpty
      ? _dueAction(language, sortedDue.first)
      : nextLesson.termCount > 0
      ? _nextLessonAction(language, nextLesson)
      : _emptyAction(language, fallbackLessonId);

  final freshLesson = lessons.firstWhere(
    (lesson) => lesson.completedCount == 0,
    orElse: () => nextLesson,
  );

  final quickActions = <LibraryRoadmapAction>[
    if (primaryAction.id != 'next_${nextLesson.id}' && nextLesson.termCount > 0)
      _nextLessonAction(language, nextLesson),
    if (sortedDue.isNotEmpty && primaryAction.id != 'due_${sortedDue.first.id}')
      _dueAction(language, sortedDue.first),
    if (freshLesson.termCount > 0 &&
        freshLesson.id != nextLesson.id &&
        primaryAction.id != 'fresh_${freshLesson.id}')
      _freshLessonAction(language, freshLesson),
    _lookupAction(language, level),
  ].take(3).toList(growable: false);

  final headlineAndCaption = _headlineAndCaption(
    language: language,
    dueLessons: sortedDue.length,
    inProgressLessons: inProgress.length,
    completionRate: completionRate,
    nextLesson: nextLesson,
    hasAnyLessons: lessons.isNotEmpty,
  );

  return LibraryRoadmapBoard(
    headline: headlineAndCaption.$1,
    caption: headlineAndCaption.$2,
    primaryAction: primaryAction,
    quickActions: quickActions,
    stats: [
      LibraryRoadmapStat(
        label: _l(language, en: 'Completion', vi: 'Hoàn thành', ja: '完了'),
        value: '$completionRate%',
        detail: totalLessons == 0
            ? _l(
                language,
                en: 'No lesson progress yet.',
                vi: 'Chưa có tiến độ lesson nào.',
                ja: 'まだレッスン進捗はありません。',
              )
            : _l(
                language,
                en: '$completedTerms of $totalTerms terms are already covered.',
                vi: '$completedTerms trên $totalTerms mục đã được chạm tới.',
                ja: '$totalTerms項目中$completedTerms項目が進んでいます。',
              ),
        icon: Icons.pie_chart_rounded,
        color: const Color(0xFF2563EB),
      ),
      LibraryRoadmapStat(
        label: _l(language, en: 'Review load', vi: 'Tải review', ja: '復習負荷'),
        value: '${sortedDue.length}',
        detail: sortedDue.isEmpty
            ? _l(
                language,
                en: 'No lesson is flashing due pressure right now.',
                vi: 'Hiện chưa có lesson nào đang chớp áp lực review.',
                ja: '今はレビュー圧が高いレッスンはありません。',
              )
            : _l(
                language,
                en: '${sortedDue.first.dueCount} due items are concentrated in ${sortedDue.first.title}.',
                vi: '${sortedDue.first.dueCount} mục đến hạn đang dồn ở ${sortedDue.first.title}.',
                ja: '${sortedDue.first.title}に${sortedDue.first.dueCount}件の期限項目があります。',
              ),
        icon: Icons.schedule_rounded,
        color: const Color(0xFFD97706),
      ),
      LibraryRoadmapStat(
        label: _l(language, en: 'Active', vi: 'Đang học', ja: '進行中'),
        value: '${inProgress.length}',
        detail: inProgress.isEmpty
            ? _l(
                language,
                en: 'You can open a fresh lesson without much carry-over.',
                vi: 'Bạn có thể mở một lesson mới mà không bị kéo theo quá nhiều phần dang dở.',
                ja: '持ち越しが少ないので新しいレッスンを開きやすい状態です。',
              )
            : _l(
                language,
                en: '${inProgress.first.title} is the strongest in-progress candidate right now.',
                vi: '${inProgress.first.title} là lesson đang học đáng quay lại nhất lúc này.',
                ja: '${inProgress.first.title} が今戻る価値の高い進行中レッスンです。',
              ),
        icon: Icons.track_changes_rounded,
        color: const Color(0xFF0F766E),
      ),
    ],
  );
}

LibraryRoadmapAction _dueAction(AppLanguage language, LessonMeta lesson) {
  return LibraryRoadmapAction(
    id: 'due_${lesson.id}',
    title: _l(
      language,
      en: 'Clean review pressure in ${lesson.title}',
      vi: 'Dọn áp lực review ở ${lesson.title}',
      ja: '${lesson.title} のレビュー圧を下げる',
    ),
    subtitle: _l(
      language,
      en: '${lesson.dueCount} due terms are waiting inside this lesson right now.',
      vi: '${lesson.dueCount} mục đến hạn đang chờ bên trong lesson này.',
      ja: 'このレッスン内で${lesson.dueCount}件の期限項目が待っています。',
    ),
    ctaLabel: _l(
      language,
      en: 'Open priority lesson',
      vi: 'Mở lesson ưu tiên',
      ja: '優先レッスンへ',
    ),
    route: AppRouteLocation.lessonDetail(lesson.id),
    icon: Icons.schedule_rounded,
    color: const Color(0xFFD97706),
    badge: _l(
      language,
      en: '${lesson.dueCount} due',
      vi: '${lesson.dueCount} đến hạn',
      ja: '${lesson.dueCount}件',
    ),
  );
}

LibraryRoadmapAction _nextLessonAction(
  AppLanguage language,
  LessonMeta lesson,
) {
  final isFresh = lesson.completedCount == 0;
  return LibraryRoadmapAction(
    id: 'next_${lesson.id}',
    title: isFresh
        ? _l(
            language,
            en: 'Start ${lesson.title}',
            vi: 'Bắt đầu ${lesson.title}',
            ja: '${lesson.title} を始める',
          )
        : _l(
            language,
            en: 'Resume ${lesson.title}',
            vi: 'Học tiếp ${lesson.title}',
            ja: '${lesson.title} を再開する',
          ),
    subtitle: isFresh
        ? _l(
            language,
            en: '${lesson.termCount} terms are waiting in a clean lesson block.',
            vi: '${lesson.termCount} mục đang chờ trong một lesson còn sạch.',
            ja: '${lesson.termCount}項目の新しいレッスンが待っています。',
          )
        : _l(
            language,
            en: '${lesson.completedCount}/${lesson.termCount} terms are already moving in this lesson.',
            vi: '${lesson.completedCount}/${lesson.termCount} mục đã được đụng trong lesson này.',
            ja: 'このレッスンは${lesson.completedCount}/${lesson.termCount}項目まで進んでいます。',
          ),
    ctaLabel: _l(
      language,
      en: isFresh ? 'Start lesson' : 'Resume lesson',
      vi: isFresh ? 'Bắt đầu lesson' : 'Học tiếp lesson',
      ja: isFresh ? 'レッスン開始' : 'レッスン再開',
    ),
    route: AppRouteLocation.lessonDetail(lesson.id),
    icon: isFresh ? Icons.play_lesson_rounded : Icons.menu_book_rounded,
    color: const Color(0xFF2563EB),
    badge: isFresh
        ? _l(language, en: 'Fresh', vi: 'Mới', ja: '新規')
        : _l(language, en: 'In progress', vi: 'Đang học', ja: '進行中'),
  );
}

LibraryRoadmapAction _freshLessonAction(
  AppLanguage language,
  LessonMeta lesson,
) {
  return LibraryRoadmapAction(
    id: 'fresh_${lesson.id}',
    title: _l(
      language,
      en: 'Keep a fresh lesson ready',
      vi: 'Giữ sẵn một lesson mới',
      ja: '新しいレッスンを用意する',
    ),
    subtitle: _l(
      language,
      en: '${lesson.title} is the cleanest place to expand after review is stable.',
      vi: '${lesson.title} là chỗ sạch nhất để mở rộng sau khi review ổn định.',
      ja: '${lesson.title} は復習が落ち着いた後に広げやすい入口です。',
    ),
    ctaLabel: _l(
      language,
      en: 'Open fresh lesson',
      vi: 'Mở lesson mới',
      ja: '新規レッスンへ',
    ),
    route: AppRouteLocation.lessonDetail(lesson.id),
    icon: Icons.play_circle_outline_rounded,
    color: const Color(0xFF16A34A),
    badge: _l(language, en: 'Expand', vi: 'Mở rộng', ja: '拡張'),
  );
}

LibraryRoadmapAction _lookupAction(AppLanguage language, StudyLevel level) {
  return LibraryRoadmapAction(
    id: 'lookup',
    title: _l(
      language,
      en: 'Search the ${level.shortLabel} bank faster',
      vi: 'Tra nhanh bank ${level.shortLabel}',
      ja: '${level.shortLabel}バンクを素早く検索する',
    ),
    subtitle: _l(
      language,
      en: 'Jump straight into words, kanji, and readings when you need context.',
      vi: 'Nhảy thẳng vào từ, kanji và cách đọc khi bạn cần ngữ cảnh ngay.',
      ja: '語彙・漢字・読みをすぐ引きたい時の近道です。',
    ),
    ctaLabel: _l(language, en: 'Open lookup', vi: 'Mở tra cứu', ja: '検索へ'),
    route: AppRoutePath.search,
    icon: Icons.search_rounded,
    color: const Color(0xFF7C3AED),
    badge: level.shortLabel,
  );
}

LibraryRoadmapAction _emptyAction(AppLanguage language, int fallbackLessonId) {
  return LibraryRoadmapAction(
    id: 'empty_$fallbackLessonId',
    title: _l(
      language,
      en: 'Open the first lesson',
      vi: 'Mở lesson đầu tiên',
      ja: '最初のレッスンを開く',
    ),
    subtitle: _l(
      language,
      en: 'This level has no tracked lesson progress yet, so start from the first block.',
      vi: 'Level này chưa có tiến độ lesson nào được theo dõi, nên hãy vào block đầu tiên.',
      ja: 'このレベルにはまだ進捗がないので、最初のブロックから始めましょう。',
    ),
    ctaLabel: _l(
      language,
      en: 'Open first lesson',
      vi: 'Mở lesson đầu',
      ja: '最初のレッスンへ',
    ),
    route: AppRouteLocation.lessonDetail(fallbackLessonId),
    icon: Icons.play_lesson_rounded,
    color: const Color(0xFF2563EB),
  );
}

(String, String) _headlineAndCaption({
  required AppLanguage language,
  required int dueLessons,
  required int inProgressLessons,
  required int completionRate,
  required LessonMeta nextLesson,
  required bool hasAnyLessons,
}) {
  if (dueLessons > 0) {
    return (
      _l(
        language,
        en: 'Stabilize the lesson queue first',
        vi: 'Ổn định hàng lesson trước',
        ja: 'まずレッスンのキューを安定させる',
      ),
      _l(
        language,
        en: 'Library says review pressure has returned inside your active lessons.',
        vi: 'Library cho thấy áp lực review đã quay lại bên trong các lesson đang mở.',
        ja: 'ライブラリ上では進行中レッスンのレビュー圧が戻ってきています。',
      ),
    );
  }
  if (inProgressLessons > 0) {
    return (
      _l(
        language,
        en: 'Close open loops before opening too many more',
        vi: 'Khép các vòng mở trước khi mở thêm',
        ja: '新しく広げる前に開いたループを閉じる',
      ),
      _l(
        language,
        en: 'You already have lessons in motion, so the cheapest progress is to keep them moving.',
        vi: 'Bạn đã có lesson đang chạy, nên tiến bộ rẻ nhất lúc này là đẩy tiếp chúng đi.',
        ja: 'すでに動いているレッスンがあるので、まずはその流れを続けるのが最短です。',
      ),
    );
  }
  if (hasAnyLessons) {
    return (
      _l(
        language,
        en: 'Open the next clean lesson',
        vi: 'Mở lesson sạch tiếp theo',
        ja: '次のきれいなレッスンを開く',
      ),
      _l(
        language,
        en: '$completionRate% of the level is already familiar, so you can expand with confidence.',
        vi: '$completionRate% của level đã quen tay, nên bạn có thể mở rộng khá tự tin.',
        ja: 'レベルの$completionRate%はすでに触れているので、安心して広げられます。',
      ),
    );
  }
  return (
    _l(
      language,
      en: 'Start building the level map',
      vi: 'Bắt đầu dựng bản đồ level',
      ja: 'レベルの地図を作り始める',
    ),
    _l(
      language,
      en: 'There is no tracked lesson activity yet, so begin from the first lesson.',
      vi: 'Chưa có hoạt động lesson nào được theo dõi, nên hãy bắt đầu từ bài đầu tiên.',
      ja: 'まだ追跡されたレッスン活動がないので、最初のレッスンから始めましょう。',
    ),
  );
}

String _fallbackLessonTitle(AppLanguage language, int lessonId) {
  return _l(
    language,
    en: 'Lesson $lessonId',
    vi: 'Bài $lessonId',
    ja: 'レッスン $lessonId',
  );
}

String _l(
  AppLanguage language, {
  required String en,
  required String vi,
  required String ja,
}) {
  switch (language) {
    case AppLanguage.en:
      return en;
    case AppLanguage.vi:
      return vi;
    case AppLanguage.ja:
      return ja;
  }
}
