# Neo-Japanese Desktop UI Redesign

## Goal
Make the desktop interface more visually appealing for young learners with authentic Japanese aesthetic elements, while keeping the existing mobile experience intact.

## Approach: Neo-Japanese Minimal + Kawaii accents

---

## Batch 1 — Quick Wins

### 1. Seigaiha Background Pattern
**File:** `lib/features/common/widgets/japanese_background.dart`
- Replace `_WavePatternPainter` (circle grid) with seigaiha (traditional wave) pattern
- Seigaiha: concentric quarter-circles arranged in overlapping rows
- Keep same color logic (light/dark adaptive), same opacity level
- Vector CustomPaint — no image assets needed

### 2. Desktop 2-Column "Today" Layout
**File:** `lib/features/home/screens/learning_path_screen.dart`
- Current desktop "Today" tab: single centered column (DailySessionCard + MiniDashboard + DiscoverPracticePanel)
- New layout: Row with sidebar (width ~300px) + main content
  - **Sidebar:** Mascot fox (larger), streak flame, quick stats (XP today, due reviews, ghost count)
  - **Main:** DailySessionCard + MiniDashboard + DiscoverPracticePanel (existing)
- Only applies when `isDesktop == true`, mobile unchanged
- Sidebar wrapped in a HomeSurface-style panel

### 3. Section Dividers with Japanese Motif
**File:** New `lib/core/widgets/japanese_divider.dart`
- Replace bare `SizedBox(height: 10)` between desktop sections
- Thin horizontal line with small centered icon (torii gate via Unicode ⛩ or wave ～)
- Subtle, not distracting — same color as border tones

---

## Batch 2 — Deeper Polish

### 4. Sakura Particle Animation
**File:** New `lib/features/common/widgets/sakura_particles.dart`
- 5-8 petal shapes drifting diagonally across screen
- CustomPainter + AnimationController, GPU-accelerated (transform only)
- Desktop only (skip on mobile for performance)
- Respects `MediaQuery.disableAnimations` / reduced-motion
- Petals: pink (#FFB7C5) with slight rotation, 8-12s drift duration

### 5. Japanese Display Font
**File:** `lib/app/theme/app_theme.dart`, `pubspec.yaml`
- Add Zen Antique Soft (Google Fonts) for `displayLarge` and `titleLarge`
- Body text stays Noto Sans JP (readability)
- Creates visual hierarchy contrast between headings and body

### 6. Hanko-Style Achievement Badges
**File:** `lib/features/home/home_screen.dart` (_AchievementDialog)
- Achievement popup redesigned as circular red seal (hanko stamp)
- Red circle (#D1493F vermilion), white text, slight rotation (-5°)
- Ink stamp texture effect via subtle border variation
- Applies to _AchievementDialog and any achievement display widgets

---

## Files to Modify
- `lib/features/common/widgets/japanese_background.dart` — #1
- `lib/features/home/screens/learning_path_screen.dart` — #2
- `lib/core/widgets/japanese_divider.dart` (new) — #3
- `lib/features/common/widgets/sakura_particles.dart` (new) — #4
- `lib/app/theme/app_theme.dart` + `pubspec.yaml` — #5
- `lib/features/home/home_screen.dart` — #6

## Design Constraints
- No image assets — all patterns via CustomPaint/vector
- Mobile layout unchanged
- Respect reduced-motion preferences
- Keep existing color palette (Aizome, Matcha, Vermilion)
- Performance: particle animations use only transform/opacity
