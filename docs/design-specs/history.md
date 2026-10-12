# History Design Spec

## Layout
- Scaffold → SafeArea(bottom: false) → Column.
- Children:
  1. `DemoTopBar` (height 64).
  2. Expanded → ListView (padding fromLTRB 28,18,28,24).
- Inside ListView (vertical):
  - Centered circular icon container (52 dp) with `Icons.receipt_long_outlined` (color `AppColors.primary`).
  - SizedBox(height: 10).
  - Title **History** (centered, style `AppTextStyles.sectionTitle`, fontSize 22, color `AppColors.textPrimary`).
  - SizedBox(height: 2).
  - Subtitle **Total Seluruh Ketring:** (centered, style `AppTextStyles.bodySmall`, color `AppColors.textSecondary`).
  - Total amount text (centered, style `AppTextStyles.bodyMedium`, color `AppColors.primary`).
  - SizedBox(height: 12).
  - `_HistoryFilters` widget (custom filter tabs All/Settled/Unsettled).
  - SizedBox(height: 16).
  - If `orders.isEmpty` -> centered placeholder text **Tidak ada pesanan pada filter ini.**
  - Else → list of `_HistoryCard` for each order:
    * Card container with `AppColors.peach` background, radius `AppRadius.md`.
    * Top row: order date (style `AppTextStyles.caption`) on left, status circle (green `AppColors.successSoft` if paid, red `AppColors.dangerSoft` otherwise) with icon (`Icons.check_circle_outline` or `Icons.error_outline`).
    * Order week title (`AppTextStyles.sectionTitle`, fontSize 20).
    * For each day in order.days → `_HistoryDetailRow` with icon `Icons.restaurant` and day text.
    * Row for payment info with icon `Icons.payments_outlined`, text `order.payment`, amount formatted `demoRupiah(order.amount)` (color primary if paid, error if not).
    * If not paid → `DemoPrimaryButton` **Bayar Sekarang** at bottom.

## Spacing & Padding
- Page padding: left/right 28, top 18, bottom 24.
- Card inner padding: EdgeInsets.all(12).
- Vertical gaps as listed (10,2,12,16, etc.).
- `_HistoryDetailRow` internal padding: horizontal 10, vertical 7.

## Typography
- Title **History**: `AppTextStyles.sectionTitle`.
- Subtitle **Total Seluruh Ketring:**: `AppTextStyles.bodySmall`.
- Total amount: `AppTextStyles.bodyMedium` (bold, primary color).
- Filter tabs use internal widget style (not explicit here).
- Order date: `AppTextStyles.caption`.
- Week title: `AppTextStyles.sectionTitle` (fontSize 20).
- Day rows: `AppTextStyles.bodySmall`.
- Payment row: `AppTextStyles.bodyMediumBold` for amount, `AppTextStyles.bodySmall` for label.
- Button **Bayar Sekarang**: `AppTextStyles.buttonLarge`.

## Colors (hex)
- Background: `AppColors.background` (`#FFF8F3`).
- Card background: `AppColors.peach` (`#FFE3B1`).
- Icon color: `AppColors.primary` (`#9E003A`).
- Text primary: `AppColors.textPrimary` (`#2A1A0A`).
- Text secondary: `AppColors.textSecondary` (`#5A4A4A`).
- Success (paid) circle: `AppColors.successSoft` (`#E8F8EE`).
- Error (unpaid) circle: `AppColors.dangerSoft` (`#FFDAD6`).
- Amount color when unpaid: `AppColors.error`.
- Border selected for filters: `AppColors.borderSelected`.

## Shape & Radius
- Card radius: `AppRadius.md` (12).
- Icon container (receipt) radius: 52 dp circle.
- Buttons use `DemoPrimaryButton` radius `AppRadius.md`.

## Components
- `DemoTopBar`
- `_HistoryFilters`
- `_HistoryCard`
- `_HistoryDetailRow`
- `DemoPrimaryButton`

## State
- Orders loaded from `demoOrderProvider.orders` (mock data).
- Filter index `_filter` (0 All, 1 Paid, 2 Unpaid).
- Payment status influences icon/color and presence of **Bayar Sekarang** button.

## Exact Text
- Header: **History**
- Sub‑header: **Total Seluruh Ketring:**
- Button: **Bayar Sekarang**
- Placeholder when empty: **Tidak ada pesanan pada filter ini.**
- Icon tooltip not used.

---
