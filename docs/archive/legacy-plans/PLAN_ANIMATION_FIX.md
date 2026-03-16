# Animation Fix Plan: "Make it Move!"

> **Problem:** Rive package integration issues are causing the mascot to remain static (fallback mode).
> **Goal:** Immediately restore and enhance "Duolingo-style" liveliness using `flutter_animate` (Pro Max quality) on the fallback image.

## 1. Strategy: "Code-Driven Animation" (The Polyfill)
Since Rive is blocked by environment analysis issues, we will replicate the desired "Rive Behaviors" using Flutter's native animation library (`flutter_animate`), which is already working in the project.

| Rive State | Flutter Animate Equivalent | Implementation |
|------------|---------------------------|----------------|
| **Idle** | Organic Breathing + Float | `Scale` (1.0 -> 1.05) + `MoveY` (-5px) in non-sync loops. |
| **Hover** | Subtle Rotate/Tilt | `Rotate` (-0.02 -> 0.02). |
| **Success** | Jump + Bounce | `MoveY` (Jump) + `Scale` (Squash/Stretch) on Tap. |

## 2. Phase Planning

| Phase | Agent | Action |
|-------|-------|--------|
| **1. Planning** | `project-planner` | Define animation curves and states. |
| **2. Implementation** | `frontend-specialist` | Update `mascot_rive.dart` to apply animations to the `Image.asset` fallback. |
| **3. Verification** | `test-engineer` | Verify `flutter analyze` passes. |

## 3. Technical Specs (`frontend-specialist`)
**File:** `lib/features/home/widgets/mascot_rive.dart`
**Logic:**
- Keep the `MascotRive` class structure.
- Wrap the `Image.asset` fallback in an `Animate` chain.
- Restoration: Bring back the "Organic" logic created in Step 939 but improved.
- **Sparkle:** Add a separate `Icon(Icons.star)` or similar that animates on 'Success' if possible, or just focus on the fox for now.

## 4. Verification (`test-engineer`)
- `flutter analyze` must be 100% clean.

---
**Status:** Waiting for approval.
