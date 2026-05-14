# D6 Contrast Audit - Q6.5 Violation Register

Source: `D6-ui-ux/Q6.5-*`.

Method: manual WCAG 2.1 contrast calculation from actual theme tokens, alpha-blended over sampled surfaces. Normal text threshold: `4.5:1`; large text threshold: `3:1`.

## Violations / Risks

| Surface | Token / component | Ratio | Status | Action |
|---|---|---:|---|---|
| Input hints | `palette.ink.withValues(alpha: 0.42)` on `elevated` | `2.57:1` | fail | Raise to `ink 0.62+` or visible label |
| Small helper text | `ink 0.45` on `base` | `2.79:1` | fail | Use `ink 0.62+` for active helper text |
| Empty/helper captions | `ink 0.50`-`0.55` on light surfaces | `3.18`-`3.74:1` | large-only | Use only for large text or raise opacity |
| Warning text | `palette.warning` on `base` | `2.98:1` | fail | Darken warning foreground or use `ink` text |
| `AppStatusChip.warning` | warning foreground on warning-tinted bg | `2.55:1` | fail | Change foreground treatment |
| `AppStatusChip.success` | success foreground on success-tinted bg | `3.39:1` | large-only | Change small-chip foreground treatment |
| Semantic small chips | success/info/error/accent text on light surfaces | `3.29`-`4.40:1` | large-only | Use contrast-safe semantic foregrounds |
| Disabled-ish text | `ink 0.35` on `base` | `2.14:1` | exempt but weak | Keep only for inactive controls, not helper copy |

## Passes

- Sidebar inactive labels: `6.35`-`6.43:1`.
- Mobile nav inactive labels: `4.97:1`.
- Light body text: `6.56:1`.
- Light primary/secondary text: `12.31:1` and `6.25:1`.
- Dark body text: `5.95:1`.
- Dark `ink 0.55`: `5.28:1`.

## Recommendation

Fix token policy before one-off surface edits. First patch: hint text, `AppStatusChip`, and small semantic chip foregrounds. Then add a palette contrast test to prevent regressions.
