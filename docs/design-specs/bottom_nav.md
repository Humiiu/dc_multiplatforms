# Bottom Navigation Design Spec

## Layout
- Implemented in `lib/ui/main_shell.dart` as a `Scaffold` with a `bottomNavigationBar`.
- Bottom bar is a `SizedBox` with height 64, wrapped in a `SafeArea` (top:false, bottom:false) and centered via `Align`.
- ConstrainedBox maxWidth 390, then a `ClipRect` → `BackdropFilter` (blur sigmaX 12, sigmaY 12).
- Container inside has:
  * Height 64, horizontal margin 24.
  * Background color `AppColors.background` with alpha 0.8.
  * BoxShadow (color `0x0A9E013A`, blurRadius 8, offset (0,-1)).
- Row contains four `_NavItem` widgets (Home, Order, History, Profile).
- Each `_NavItem` is an `Expanded` InkWell:
  * Icon (selected: filled, unselected: outline where applicable).
  * Label below icon.
  * Color: `AppColors.primary` when selected, otherwise `Color(0xFF4A3A3A)`.
  * Padding via InkWell, border radius 14.
- Navigation logic: `_index` determines selected index based on current route; `_navigate` pushes appropriate route.

## Spacing & Padding
- Bottom navigation height: 64.
- Horizontal margin: 24 (so bar width = screen width – 48).
- Icon‑label vertical spacing: Icon size 24, SizedBox(height: 4) before label.
- InkWell expands to fill equal width for each of the four items.

## Typography
- Label style via `AppTextStyles.navLabel` (default) or `AppTextStyles.navLabelSelected` when selected.
- Font weight medium (500) for selected, normal otherwise.

## Colors (hex)
- Background of bar: `AppColors.background` (`#FFF8F3`) with 80 % opacity.
- Selected icon/label color: `AppColors.primary` (`#9E003A`).
- Unselected icon/label color: `#4A3A3A` (dark gray).
- Shadow color: `0x0A9E013A` (transparent maroon).

## Shape & Radius
- Bar container corners are not rounded (full width). Individual nav items have InkWell borderRadius 14.
- Icon shapes are default material icons.

## Components
- `_NavItem` (custom widget handling tap, visual state).
- `GoRouter` for navigation.

## State
- Selected index calculated from `GoRouterState.of(context).matchedLocation`.
- Tapping an item calls `_navigate` to push the route.

## Exact Text
- Labels: **Home**, **Order**, **History**, **Profile** (capitalized as shown).

---
