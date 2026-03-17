# Important User Requirements

Update this file whenever the user gives a persistent preference, constraint, or quality bar that should survive future sessions.

## Active Requirements

- Vietnamese UI must render cleanly and consistently.
  Use Vietnamese-safe Latin typography for `AppLanguage.vi`, keep `Locale('vi', 'VN')`, and avoid routing Vietnamese UI through Japanese-first font stacks.
- New Vietnamese UI copy should be centralized whenever practical.
  Prefer `lib/core/app_language.dart` or a dedicated localization layer over scattered hard-coded widget strings.
- Home UI should stay compact and visually balanced.
  Avoid oversized `Progress` and `Practice` sections.
- Study UI should feel cleaner and more intentional.
  Prefer a prioritized, outcome-first layout over long repetitive lists.
- Study aesthetic should stay minimalist, premium, and distinctly Japanese-inspired.
  Favor paper-like surfaces, thin borders, restrained ink/vermilion accents, and avoid loud gradients or busy dashboard styling.
- Study should visually align with Home first.
  Reuse Home's gradient hero, soft panels, compact spacing, and bright tinted action cards instead of introducing a separate visual language.
- Distinct Study functions should not share ambiguous labels.
  Avoid duplicate names like `Mistakes` for different routes; prefer labels that explain the actual job such as grammar repair vs. weak points.
- Feature redesigns should leverage existing in-app data first.
  Prefer real diagnostics, counts, sections, progress, and current user context over placeholder panels or decorative filler UI.
- Immersion should not surface `NHK Easy` anymore.
  Keep the reading experience focused on the in-app reading bank instead of showing NHK source tabs or fallback notices.
- Sakura background should remain visibly denser than the original sparse version.
- Continue appending meaningful implementation history to `docs/logs/codex-work-log.md`.
