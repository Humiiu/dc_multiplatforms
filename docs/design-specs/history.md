# History Design Spec

## Layout
- Scaffold → SafeArea(bottom: false) → Column.
- Children:
  1. `DemoTopBar` (height 64).
  2. Expanded → ListView (padding fromLTRB 28, 8, 28, 24).
- Inside ListView (vertical):
  - Title **History** (left-aligned, style `AppTextStyles.welcome`, fontSize 28, color `AppColors.primaryDark`).
  - SizedBox(height: 4).
  - Subtitle **hhhhhhhhhhhhhhistory** (left-aligned, style `AppTextStyles.bodySmall`, color `AppColors.textSecondary`).
  - SizedBox(height: 14).
  - `_HistoryFilters` widget (Row filter tabs: Semua, Sudah Lunas, Belum Lunas; height 38, radius 12, flat, flex [7, 10, 8], gap 12).
  - SizedBox(height: 16).
  - If `orders.isEmpty` -> centered placeholder text **Tidak ada pesanan pada filter ini.**
  - Else → list of `_HistoryCard` for each order:
    * Card container with `AppColors.card` (white) background, left status border indicator (green if paid, red if unpaid), radius `AppRadius.md`.
    * Top row: order date on left, status circle (green checkmark if paid, red clock if unpaid).
    * Order week title (`AppTextStyles.sectionTitle`, fontSize 20).
    * For each day in order.days → `_HistoryDetailRow` with icon `Icons.restaurant` and day text.
    * Row for payment info with icon `Icons.payments_outlined`, text `order.payment`, amount formatted `demoRupiah(order.amount)`.
    * If not paid → `DemoPrimaryButton` **Bayar Sekarang** at bottom.

## Spacing & Padding
- Page padding: left/right 28, top 8, bottom 24.
- Card inner padding: EdgeInsets.all(12).
- Vertical gaps: 4, 14, 16, 12.
- `_HistoryDetailRow` internal padding: horizontal 10, vertical 7.

## Typography
- Title **History**: `AppTextStyles.welcome` (Playfair Display, fontSize 28, color `AppColors.primaryDark`).
- Subtitle **hhhhhhhhhhhhhhistory**: `AppTextStyles.bodySmall` (color `AppColors.textSecondary`).
- Filter tabs: Plus Jakarta Sans, fontSize 13, FontWeight.w600.
- Order date: `AppTextStyles.caption`.
- Week title: `AppTextStyles.sectionTitle` (fontSize 20).
- Day rows: `AppTextStyles.bodySmall`.
- Payment row: `AppTextStyles.bodyMediumBold` for amount, `AppTextStyles.bodySmall` for label.
- Button **Bayar Sekarang**: `AppTextStyles.buttonLarge`.

## Colors (hex)
- Background: `AppColors.background` (`#FFF8F3`).
- Card background: `Colors.white` with `AppColors.peach` detail rows.
- Title: `AppColors.primaryDark` (`#7C1036`).
- Text secondary: `AppColors.textSecondary` (`#5A4A4A`).
- Success: `AppColors.success`.
- Error: `AppColors.error`.

## Components
- `DemoTopBar`
- `_HistoryFilters`
- `_HistoryCard`
- `_HistoryDetailRow`
- `DemoPrimaryButton`

## State
- Orders loaded from `demoOrderProvider.orders` (mock data).
- Filter index `_filter` (0 All, 1 Paid, 2 Unpaid).

## Exact Text
- Header: **History**
- Sub‑header: **hhhhhhhhhhhhhhistory**
- Filter tabs: **Semua**, **Sudah Lunas**, **Belum Lunas**
- Button: **Bayar Sekarang**
- Placeholder when empty: **Tidak ada pesanan pada filter ini.**
