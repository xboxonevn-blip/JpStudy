# Responsive Design System

JpStudy must scale from narrow phones to desktop without route-specific layout hacks.

## Rules
- Use `AppPageShell` for scrollable app pages.
- Use `AppResponsiveFrame` for max-width + page gutters.
- Use `AppFluidGrid` for cards instead of manual `Wrap` item widths.
- Use `AppFluidTwoPane` for side-by-side panels that stack on mobile.
- Use `AppResponsiveSection` for vertical page sections with viewport-aware gaps.
- Avoid new hard-coded breakpoint checks in feature screens unless there is a product reason.

## Viewport Matrix
- Phone small: `360×800`
- Phone standard: `414×896`
- Tablet: `768×1024`
- Laptop: `1366×768`
- Desktop: `1920×1080`

Any touched hub/detail route should be smoke-tested across this matrix for:
- no blank content after first frame;
- no overflow exceptions;
- primary CTA visible/reachable;
- nav still routes correctly.

## Migration
When editing a screen, replace local `LayoutBuilder` column math with:
- `AppFluidGrid(children: [...])` for feature cards;
- `AppFluidTwoPane(primary: ..., secondary: ...)` for main + aside;
- `AppResponsiveSection(children: [...])` for stacked sections.

Do not patch a single viewport by adding another `if (isMobile)` branch unless it is temporary and tracked for removal.
