# Home Design Spec

## Layout
- Scaffold → SafeArea(bottom: false) → ListView (padding fromLTRB 28,8,28,24).
- Children order:
  1. `DemoTopBar` (custom app bar).
  2. SizedBox(height: 8).
  3. Text **WELCOME** (style `AppTextStyles.bodyMedium`, color `AppColors.textSecondary`).
  4. Text greeting (e.g. `Selamat Siang, Humiiu!`) – style `AppTextStyles.welcome`, fontSize 29, color `AppColors.textPrimary`.
  5. SizedBox(height: 24).
  6. `_DebtCard` (CTA “Atur Preferensi”).
  7. SizedBox(height: 26).
  8. `DemoSectionTitle` with title **Weekly Menu** and trailing TextButton **See All ›**.
  9. Horizontal PageView carousel of `_WeeklyMenuItem` cards (viewportFraction 0.72, auto‑scroll each 4 s). Each card:
     - Date line (e.g. “Senin, 27 Okt”) – style `AppTextStyles.caption`.
     - Title (menu name) – style `AppTextStyles.sectionTitle`.
     - Subtitle – style `AppTextStyles.bodySmall`.
     - Background gradient `AppColors.surfaceVariant`.
     - Corner radius 28, shadow `AppShadows.card`.
 10. SizedBox(height: 16) after carousel.
 11. Additional sections can be appended below (not in current mock).

## Spacing & Padding
- Overall page padding: left/right 28, top 8, bottom 24.
- Card internal padding: fromLTRB 22,28,22,26.
- Card corner radius: 28.
- Gap between cards in carousel: automatically managed by PageView with 0.72 viewportFraction.
- `_DebtCard` internal padding: EdgeInsets.fromLTRB(22,28,22,26).

## Typography
- Header **WELCOME**: `AppTextStyles.bodyMedium` (color `AppColors.textSecondary`).
- Greeting line: `AppTextStyles.welcome` (fontSize 29, color `AppColors.textPrimary`).
- Weekly menu title **Weekly Menu**: `AppTextStyles.sectionTitle`.
- Date label on card: `AppTextStyles.caption`.
- Menu title on card: `AppTextStyles.sectionTitle` (fontSize default).
- Menu subtitle on card: `AppTextStyles.bodySmall`.

## Colors (hex)
- Background: `AppColors.background` (`#FFF8F3`).
- Card background: `AppColors.surfaceVariant` (`#FFF2E0`).
- Text primary: `AppColors.textPrimary` (`#2A1A0A`).
- Text secondary: `AppColors.textSecondary` (`#5A4A4A`).
- Accent for CTA button inside `_DebtCard`: `AppColors.primary` (`#9E003A`).

## Shape & Radius
- Card radius 28 (rounded rectangle).
- Button radius via `DemoPrimaryButton` (now uses `AppRadius.md`).
- Top bar height 64 (as defined in `DemoTopBar`).

## Components
- `DemoTopBar` (custom top bar, height 64).
- `_DebtCard` (custom card with gradient background, icon star, CTA button).
- `DemoSectionTitle` (title + trailing button).
- PageView with `_WeeklyMenuItem` cards.

## State
- Carousel auto‑scrolls every 4 seconds via a Timer.
- CTA button inside `_DebtCard` triggers navigation to `/checkout` via Riverpod provider.

## Exact Text
- **WELCOME** (uppercase).
- Greeting example: `Selamat Siang, Humiiu!` (dynamic from `greetings.dart`).
- Section title: **Weekly Menu**.
- CTA inside debt card: **Atur Preferensi**.
- See All button text: `See All ›`.

---
