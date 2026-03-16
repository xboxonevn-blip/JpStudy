# 🎨 UI/UX Pro Max Overhaul Plan

## 🚨 Immediate Fix: Mascot Overlap
**Problem:** The fox mascot overlaps the "Level N5" header because the layout start offset is too small.
**Fix:**
- [ ] Modify `lib/features/home/widgets/unit_map_widget.dart`
- [ ] Increase `startY` from `100.0` to `180.0`.
- [ ] Increase spacing between nodes slightly if needed.

## 🌟 Premium UI Overhaul
**Goal:** Transform the interface from "Basic/Flat" to "Premium/Modern" using Glassmorphism, Gradients, and Depth.

### 1. Dashboard Enhancements
**File:** `lib/features/home/widgets/mini_dashboard.dart`
- **Current:** Clay/Neumorphic styling (looks a bit dated or childish if not done perfectly).
- **New Design:** fit "Glassmorphism".
    - White transparency `Colors.white.withValues(alpha: 0.8)`
    - Blur effect `BackdropFilter`
    - Subtle border `Colors.white.withValues(alpha: 0.5)`
    - Colorful icon backgrounds (soft circles).

### 2. Continue Journey & Practice Buttons
**File:** `lib/features/home/widgets/continue_button.dart`
- **Current:** Solid Green/Pink bars.
- **New Design:** "Magical Cards".
    - Rich Gradients (Deep Indigo to Violet, Emerald to Teal).
    - Inner glow / localized shadow.
    - 3D press effect (scale down on tap).
    - Better typography (Outfit font if available, or Manrope).

### 3. Unit Header (Level Banner)
**File:** `lib/features/home/widgets/unit_map_widget.dart`
- **Current:** Solid Red rounded rectangle.
- **New Design:** Floating Banner.
    - Gradient text.
    - Glass background.
    - Floating shadow.

### 4. Background
**File:** `lib/features/home/home_screen.dart`
- **Current:** Simple 3-color linear gradient.
- **New Design:** Mesh Gradient or Organic Orbs (using background image or complex gradient).
    - *Action:* Enhance the existing container gradient to be softer and more vibrant.

## 🛠️ Implementation Steps (Orchestration)

### Phase 1: Planning (Current)
- [x] Analyze current state
- [x] Define design direction

### Phase 2: Execution (Frontend Agent)
- [ ] Apply Mascot Fix (`UnitMapWidget`)
- [ ] Refactor `ContinueButton` for Premium look
- [ ] Refactor `MiniDashboard` for Glassmorphism
- [ ] Update `HomeScreen` background

### Phase 3: Verification (Test Agent)
- [ ] Verify no overlaps
- [ ] Verify localization remains intact
- [ ] Run Lint check

## 📝 User Review Required
- Do you prefer **Glassmorphism** (Blur/Transparency) or **Neo-Brutalism** (High contrast, bold shadows)? *Assuming Glassmorphism/Premium based on "wow" request.*
