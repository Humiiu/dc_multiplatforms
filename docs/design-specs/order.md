# Order Design Spec

## Layout
- Scaffold → SafeArea(bottom: false) → Column.
- Children:
  1. `DemoTopBar` (height 64).
  2. Expanded → ListView (padding fromLTRB 48,20,48,24).
- Inside ListView (vertical):
  - Title **Your Order** (style `AppTextStyles.welcome`, color `AppColors.primary`, fontSize 28).
  - SizedBox(height: 8).
  - Subtitle text *Atur pesanan sesuai yang kamu mau* (style `AppTextStyles.bodySmall`, color `AppColors.textSecondary`).
  - SizedBox(height: 30).
  - Numbered title **1** Select Days (widget `_NumberedTitle`).
  - SizedBox(height: 16).
  - List of day cards (`_DayCard`) generated from `demoDays`:
    * Each card shows day name, selected state border `AppColors.borderSelected` when selected, background `AppColors.peach` otherwise.
    * Tap toggles selection via `demoOrderProvider.toggleDay`.
  - SizedBox(height: 12).
  - Numbered title **2** Order Summary (`_OrderSummary`).
  - SizedBox(height: 16).
  - Numbered title **3** Payment Method (`_PaymentChoice` widgets for Pay Now (QR‑IS) and Pay Later).
  - SizedBox(height: 20).
  - Primary button **Confirm Order** (disabled when no day selected).

## Spacing & Padding
- Page padding: left/right 48, top 20, bottom 24.
- Vertical gaps as indicated (8,30,16,12,16,20).
- Day card padding inside `_DayCard` is defined in its widget (default 12‑16). 
- Payment choice card padding: EdgeInsets.all(16).

## Typography
- Title **Your Order**: `AppTextStyles.welcome`, fontSize 28, color `AppColors.primary`.
- Subtitle: `AppTextStyles.bodySmall`.
- Numbered titles (`_NumberedTitle`): style `AppTextStyles.bodyMediumBold` for number, `AppTextStyles.bodyMedium` for title.
- Day card text: `AppTextStyles.bodyMedium` for day name, price shown as `Rp 20.000` (style `AppTextStyles.bodyMedium`).
- Payment choice title: `AppTextStyles.bodyMediumBold`.
- Payment choice subtitle: `AppTextStyles.bodySmall`.
- Button label: `AppTextStyles.buttonLarge`.

## Colors (hex)
- Background: default scaffold (`AppColors.background`).
- Day card selected background: `AppColors.selectedPink`.
- Day card unselected background: `AppColors.peach`.
- Border selected: `AppColors.borderSelected`.
- Payment choice selected background: `AppColors.selectedPink`.
- Payment choice unselected background: `AppColors.peach`.
- Primary button background: `AppColors.primary`.

## Shape & Radius
- Primary button radius via `DemoPrimaryButton` (now `AppRadius.md`).
- Day cards have rounded corners (default from widget, typically `AppRadius.md`).
- Payment choice cards use `BorderRadius.circular(AppRadius.md)`.

## Components
- `DemoTopBar`
- `_NumberedTitle`
- `_DayCard`
- `_OrderSummary`
- `_PaymentChoice`
- `DemoPrimaryButton`

## State
- `_registering` is not used here; this page uses Riverpod `demoOrderProvider`.
- Selected days stored in `order.selectedDays`.
- Payment method stored in `order.paymentMethod` (enum `DemoPaymentMethod`).
- Button disabled when `order.selectedDays.isEmpty`.

## Exact Text
- **Your Order**
- *Atur pesanan sesuai yang kamu mau*
- Numbered titles: **1**, **2**, **3**
- Section titles: **Select Days**, **Order Summary**, **Payment Method**
- Payment choice titles: **Pay Now**, **Pay Later**
- Payment choice subtitles:
  - *Pay securely online via e‑Wallet or Bank Transfer.*
  - *Due at the end of this week.*
- Button label: **Confirm Order**

---
