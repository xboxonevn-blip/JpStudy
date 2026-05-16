import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'selected user-facing source files do not contain mojibake literals',
    () {
      final bannedByFile = <String, List<String>>{
        'lib/features/custom_decks/custom_decks_screen.dart': [
          "'?????'",
          "'???????'",
          "'????????'",
          "'12???'",
          "'????'",
        ],
        'lib/features/flashcards/widgets/enhanced_flashcard.dart': [
          'Ð? nh?',
          "'??? \$pct%'",
        ],
        'lib/features/grammar/grammar_screen.dart': [
          'X?a t?m',
          'T?m ?',
          "'????????'",
        ],
        'lib/features/lesson/widgets/grammar_list_widget.dart': [
          '?? thu?c',
          '?ang h?c',
          "'????'",
        ],
        'lib/features/mistakes/screens/mistake_screen.dart': [
          'M?c ?n',
          '??????????',
        ],
        'lib/features/progress/providers/progress_coach_provider.dart': [
          'H??ng',
          '????????????????',
        ],
        'lib/features/progress/screens/review_forecast_screen.dart': [
          'L?m l?i',
          'Kh?',
          'T?t',
          'D?',
          "ja: '??'",
          "'????'",
          "'???'",
        ],
        'lib/features/search/search_screen.dart': [
          "query: '??'",
          'C?ch ??c',
          'Ngh?a',
          "'????: \$value'",
        ],
      };

      for (final entry in bannedByFile.entries) {
        final source = File(entry.key).readAsStringSync();
        for (final banned in entry.value) {
          expect(source, isNot(contains(banned)), reason: entry.key);
        }
      }
    },
  );
}
