# String literal audit (2026-03-16)

- Scope: `lib/**/*.dart`
- Goal: find user-visible literals not routed through `app_language.dart`.
- Heuristics: skip generated files, technical strings, numeric interpolation, and lines already reading localized text.

- Remaining candidates: **3**
- Files with candidates: **3**

## Remaining candidates

### `lib/features/immersion/screens/immersion_reader_screen.dart`
- `lib/features/immersion/screens/immersion_reader_screen.dart:2211` -> `$percent%`

### `lib/features/lesson/widgets/kanji_list_widget.dart`
- `lib/features/lesson/widgets/kanji_list_widget.dart:241` -> `($displayReading)`

### `lib/features/vocab/screens/term_review_screen.dart`
- `lib/features/vocab/screens/term_review_screen.dart:346` -> `$count`

## Intentional exceptions

### `lib/core/models/streak_milestone.dart`
- `lib/core/models/streak_milestone.dart:21` -> `Bronze` (data-level milestone names)
- `lib/core/models/streak_milestone.dart:28` -> `Silver` (data-level milestone names)
- `lib/core/models/streak_milestone.dart:35` -> `Gold` (data-level milestone names)
- `lib/core/models/streak_milestone.dart:42` -> `Diamond` (data-level milestone names)
- `lib/core/models/streak_milestone.dart:49` -> `Crown` (data-level milestone names)

### `lib/features/design_lab/design_lab_screen.dart`
- `lib/features/design_lab/design_lab_screen.dart:19` -> `Design Lab` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:19` -> `Design Lab` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:133` -> `Discover` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:138` -> `Visual` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:143` -> `Validate` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:220` -> `Tap targets >= 44px` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:221` -> `Text contrast pass` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:222` -> `Scroll behavior checked` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:223` -> `Animation intensity reviewed` (internal design playground)
- `lib/features/design_lab/design_lab_screen.dart:224` -> `QA walkthrough pass` (internal design playground)
