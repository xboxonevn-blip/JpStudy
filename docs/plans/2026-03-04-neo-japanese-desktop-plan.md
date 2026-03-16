# Neo-Japanese Desktop UI Implementation Plan

**Goal:** Redesign desktop UI with authentic Japanese aesthetic elements (seigaiha waves, sakura particles, torii dividers, hanko badges) and a 2-column layout to better utilize desktop screen space and appeal to young learners.

**Architecture:** Six independent visual tasks across two batches. Each task modifies or creates a single widget/file. All patterns use CustomPaint (no image assets). Mobile layout is never touched — all changes gate on `isDesktop` or use desktop-only widgets.

**Tech Stack:** Flutter CustomPaint, AnimationController, Google Fonts (Zen Antique Soft), Riverpod providers (existing)

---

### Task 1: Seigaiha Background Pattern

**Files:**
- Modify: `lib/features/common/widgets/japanese_background.dart:84-111`

**Step 1: Replace `_WavePatternPainter` with seigaiha pattern**

Replace the entire `_WavePatternPainter` class (lines 84-111) with:

```dart
class _WavePatternPainter extends CustomPainter {
  const _WavePatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const cellSize = 40.0;
    const arcs = 4;

    var row = 0;
    for (double y = -cellSize; y < size.height + cellSize * 2; y += cellSize) {
      final xShift = row.isEven ? 0.0 : cellSize;
      for (double x = -cellSize * 2; x < size.width + cellSize * 2; x += cellSize * 2) {
        final cx = x + xShift;
        final cy = y;
        for (var i = 1; i <= arcs; i++) {
          final r = cellSize * i / arcs;
          canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy), radius: r),
            3.14159, // pi — start from bottom
            3.14159, // pi — sweep half circle
            false,
            paint,
          );
        }
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _WavePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
```

**Step 2: Run flutter analyze**

Run: `flutter analyze lib/features/common/widgets/japanese_background.dart`
Expected: No issues found

**Step 3: Visual check on desktop**

Run: `flutter run -d windows`
Expected: Background shows overlapping concentric half-circles (seigaiha wave pattern) instead of circle grid. Pattern is subtle, same opacity as before.

**Step 4: Commit**

```bash
git add lib/features/common/widgets/japanese_background.dart
git commit -m "feat(ui): replace circle grid with seigaiha wave background pattern"
```

---

### Task 2: Desktop 2-Column "Today" Layout

**Files:**
- Modify: `lib/features/home/screens/learning_path_screen.dart:145-162`

**Step 1: Replace `_buildDesktopSection` Today case with 2-column layout**

Replace the `case _HomeMenuSection.today:` block (lines 147-162) inside `_buildDesktopSection` with:

```dart
      case _HomeMenuSection.today:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.desktop),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: DecoratedBox(
                      decoration: HomeSurface.softPanel(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: _DesktopSidebar(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: const [
                        DailySessionCard(compact: true),
                        SizedBox(height: 10),
                        MiniDashboard(),
                        SizedBox(height: 10),
                        DiscoverPracticePanel(initiallyExpanded: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
```

**Step 2: Add `_DesktopSidebar` widget at the bottom of the file (before closing bracket)**

Add this widget class just above the `_panelDecoration` method or at the end of the `_LearningPathScreenState` class area:

```dart
class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final language = ref.watch(appLanguageProvider);

    return dashboardAsync.when(
      data: (state) {
        final totalDue = state.vocabDue + state.grammarDue + state.kanjiDue;
        return Column(
          children: [
            // Fox mascot image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/mascot_fox_transparent.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFEF4444), size: 28),
                const SizedBox(width: 6),
                Text(
                  '${state.streak} ${language.dayStreakLabel}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Quick stats
            _SidebarStat(
              icon: Icons.bolt_rounded,
              color: const Color(0xFFF59E0B),
              label: 'XP ${language.todayLabel}',
              value: '${state.todayXp}',
            ),
            const SizedBox(height: 12),
            _SidebarStat(
              icon: Icons.rate_review_rounded,
              color: const Color(0xFF3B82F6),
              label: language.dueReviewsLabel,
              value: '$totalDue',
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SidebarStat extends StatelessWidget {
  const _SidebarStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
```

**Step 3: Add import for dashboard_provider if not already present**

Check top imports. `learning_path_screen.dart` currently does NOT import `dashboard_provider.dart`. Add:

```dart
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
```

**Step 4: Run flutter analyze**

Run: `flutter analyze lib/features/home/screens/learning_path_screen.dart`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/home/screens/learning_path_screen.dart
git commit -m "feat(ui): add 2-column desktop layout with sidebar on Today tab"
```

---

### Task 3: Japanese Section Divider

**Files:**
- Create: `lib/core/widgets/japanese_divider.dart`
- Modify: `lib/features/home/screens/learning_path_screen.dart` (desktop Today section)

**Step 1: Create `japanese_divider.dart`**

```dart
import 'package:flutter/material.dart';

class JapaneseDivider extends StatelessWidget {
  const JapaneseDivider({super.key, this.icon = '⛩'});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).dividerColor.withValues(alpha: 0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Divider(color: color, thickness: 0.8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              icon,
              style: TextStyle(fontSize: 14, color: color),
            ),
          ),
          Expanded(child: Divider(color: color, thickness: 0.8)),
        ],
      ),
    );
  }
}
```

**Step 2: Replace `SizedBox(height: 10)` dividers in desktop Today layout**

In `learning_path_screen.dart`, replace the two `SizedBox(height: 10)` in the desktop Today case (from Task 2) with:

```dart
const JapaneseDivider(),
```

Add import at top:
```dart
import 'package:jpstudy/core/widgets/japanese_divider.dart';
```

**Step 3: Run flutter analyze**

Run: `flutter analyze lib/core/widgets/japanese_divider.dart lib/features/home/screens/learning_path_screen.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/widgets/japanese_divider.dart lib/features/home/screens/learning_path_screen.dart
git commit -m "feat(ui): add torii gate section dividers for desktop layout"
```

---

### Task 4: Sakura Particle Animation

**Files:**
- Create: `lib/features/common/widgets/sakura_particles.dart`
- Modify: `lib/features/common/widgets/japanese_background.dart`

**Step 1: Create `sakura_particles.dart`**

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class SakuraParticles extends StatefulWidget {
  const SakuraParticles({super.key});

  @override
  State<SakuraParticles> createState() => _SakuraParticlesState();
}

class _SakuraParticlesState extends State<SakuraParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _petals = List.generate(7, (_) => _Petal(rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SakuraPainter(_petals, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Petal {
  _Petal(Random rng)
      : startX = rng.nextDouble(),
        speed = 0.6 + rng.nextDouble() * 0.4,
        drift = 0.02 + rng.nextDouble() * 0.06,
        phase = rng.nextDouble(),
        size = 4.0 + rng.nextDouble() * 4.0,
        rotationSpeed = 0.5 + rng.nextDouble();

  final double startX;
  final double speed;
  final double drift;
  final double phase;
  final double size;
  final double rotationSpeed;
}

class _SakuraPainter extends CustomPainter {
  _SakuraPainter(this.petals, this.t);

  final List<_Petal> petals;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x40FFB7C5);

    for (final petal in petals) {
      final progress = (t * petal.speed + petal.phase) % 1.0;
      final y = -20 + progress * (size.height + 40);
      final x = petal.startX * size.width +
          sin(progress * 3.14159 * 2 * petal.rotationSpeed) *
              size.width *
              petal.drift;
      final rotation = progress * 3.14159 * 2 * petal.rotationSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw petal shape (ellipse)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 1.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakuraPainter oldDelegate) => true;
}
```

**Step 2: Add `SakuraParticles` to `JapaneseBackground` for desktop only**

In `japanese_background.dart`, add the import at top:
```dart
import 'package:jpstudy/features/common/widgets/sakura_particles.dart';
```

Insert a new `Positioned.fill` layer after the second `_Orb` (line 57) and before the child (line 58):

```dart
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) return const SizedBox.shrink();
              return const SakuraParticles();
            },
          ),
        ),
```

**Step 3: Run flutter analyze**

Run: `flutter analyze lib/features/common/widgets/sakura_particles.dart lib/features/common/widgets/japanese_background.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/common/widgets/sakura_particles.dart lib/features/common/widgets/japanese_background.dart
git commit -m "feat(ui): add sakura petal particles on desktop background"
```

---

### Task 5: Japanese Display Font

**Files:**
- Modify: `lib/app/theme/app_theme.dart:1-106` (light theme)
- Modify: `lib/app/theme/app_theme.dart:108-155` (dark theme)

**Step 1: Add display font to light theme**

In `app_theme.dart`, inside `light()`, after `final fontName = ...` (line 21), add:

```dart
    final displayFontName = GoogleFonts.zenAntiqueSoft().fontFamily;
```

Then update `displayLarge` and `titleLarge` in the `textTheme` (lines 80-89) to use `displayFontName`:

```dart
        displayLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
```

**Step 2: Add display font to dark theme**

In `dark()`, after `final fontName = ...` (line 114), add:

```dart
    final displayFontName = GoogleFonts.zenAntiqueSoft().fontFamily;
```

Add a `textTheme` to the dark theme's `ThemeData` (currently missing). After `elevatedButtonTheme` (line 152), add:

```dart
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontFamily: fontName, color: const Color(0xFFCBD5E1)),
        bodyMedium: TextStyle(fontFamily: fontName, color: const Color(0xFF94A3B8)),
      ),
```

**Step 3: Run flutter analyze**

Run: `flutter analyze lib/app/theme/app_theme.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/app/theme/app_theme.dart
git commit -m "feat(ui): add Zen Antique Soft display font for headings"
```

---

### Task 6: Hanko-Style Achievement Badge

**Files:**
- Modify: `lib/features/home/home_screen.dart` (`_AchievementDialog`)

**Step 1: Find and redesign `_AchievementDialog`**

Locate the `_AchievementDialog` class in `home_screen.dart`. Replace its `build` method content with a hanko-stamp style:

The dialog content should be replaced with:

```dart
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hanko stamp
          Transform.rotate(
            angle: -0.09, // ~5 degrees tilt
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1493F),
                border: Border.all(
                  color: const Color(0xFFB03A32),
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            type,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
```

**Note:** You must read the existing `_AchievementDialog` first to confirm its current fields (`label`, `type`, etc.) and adapt the above code to match existing constructor params.

**Step 2: Run flutter analyze**

Run: `flutter analyze lib/features/home/home_screen.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/home/home_screen.dart
git commit -m "feat(ui): redesign achievement dialog as hanko stamp badge"
```

---

## Execution Order

Tasks 1-6 are independent. Recommended order: 1 → 4 (both background), then 2 → 3 (layout + dividers), then 5 → 6 (polish).

## Verification

After all tasks:
1. `flutter analyze` — no issues
2. `flutter test` — all existing tests pass
3. Visual check desktop: seigaiha background + sakura particles visible
4. Visual check desktop Today tab: 2-column with sidebar
5. Visual check mobile: unchanged from current
6. Visual check dark mode: patterns and sidebar adapt correctly
