import 'package:flutter/widgets.dart';

/// Returns [Duration.zero] when the user has requested reduced motion
/// (OS-level accessibility setting, exposed via
/// [MediaQueryData.disableAnimations]), otherwise returns [normal].
///
/// Use this to gate the `duration` parameter of any decorative animation
/// (e.g. [AnimatedContainer], [AnimatedOpacity], [AnimatedSwitcher]) so the
/// app honors the user's "Reduce Motion" setting on iOS or "Remove
/// animations" on Android.
///
/// ```dart
/// AnimatedContainer(
///   duration: reducedMotionDuration(context, const Duration(milliseconds: 200)),
///   // ...
/// )
/// ```
///
/// This is the canonical grep-point: anywhere in the app that animates,
/// every instance should pass its tween duration through this function.
/// Files that call this directly can be audited with a simple grep; files
/// that still hardcode `const Duration(...)` inside an `AnimatedX` widget
/// are the ones that still need to be converted.
Duration reducedMotionDuration(BuildContext context, Duration normal) =>
    MediaQuery.of(context).disableAnimations ? Duration.zero : normal;

/// Returns true when controller-driven, timer-driven, or canvas-driven motion
/// should be stopped entirely rather than merely shortened.
bool reducedMotionEnabled(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;
