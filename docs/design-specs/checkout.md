# Checkout Design Spec

## Layout
- Scaffold → SafeArea → Column.
- Children:
  1. `DemoTopBar` with title **Checkout**, `showBack: true`.
  2. Expanded → ListView (padding fromLTRB 28,0,28,20).
- Inside ListView (vertical):
  - Container (gradient background) showing **TOTAL BILL** and the amount:
    * Height: auto, vertical padding 28.
    * Gradient colors: `AppColors.surfaceVariant` → `AppColors.background`.
    * Bottom border radius `AppRadius.xxl`.
    * Text **TOTAL BILL** style `AppTextStyles.bodyMedium` (color `AppColors.textSecondary`, letterSpacing 1.2).
    * Amount displayed with `RichText` using `AppTextStyles.priceLarge` (color `AppColors.primary`, fontSize 40) and prefix **Rp** styled with `AppTextStyles.bodyMedium` (color `AppColors.textPrimary`, fontSize 22).
  - SizedBox(height: 28).
  - Text **Payment Method** (style `AppTextStyles.sectionTitle`, fontSize 22).
  - SizedBox(height: 18).
  - Two `_CheckoutMethodCard` widgets for **QRIS** and **Virtual Account / E‑Wallet**:
    * Each card shows title, detail description, an icon, and a radio‑button indicator.
    * Selected card background: `AppColors.selectedPink` if selected, otherwise `AppColors.peach`.
    * Border radius `AppRadius.md`.
    * Icon size 22, color `AppColors.primary`.
  - SizedBox(height: 20).
  - Primary button **Bayar Sekarang** (`DemoPrimaryButton`), enabled when a payment method is selected.

## Spacing & Padding
- Overall page padding: left/right 28, bottom 20.
- Gradient container vertical padding: 28.
- Gaps between sections: 28, 18, 20 as listed.
- `_CheckoutMethodCard` internal padding: EdgeInsets.all(16).
- Card margin bottom: 12.

## Typography
- Header **Checkout** (in `DemoTopBar`).
- Section title **Payment Method**: `AppTextStyles.sectionTitle` (fontSize 22).
- **TOTAL BILL**: `AppTextStyles.bodyMedium` (letterSpacing 1.2).
- Amount **Rp …**: `AppTextStyles.priceLarge` (color `AppColors.primary`, fontSize 40) with prefix **Rp** styled separately.
- Card titles (**QRIS**, **Virtual Account/E‑Wallet**) – style `AppTextStyles.bodyMediumBold`.
- Card details – style `AppTextStyles.bodySmall` (fontSize 15).
- Button label **Bayar Sekarang** – style `AppTextStyles.buttonLarge`.

## Colors (hex)
- Background: `AppColors.background` (`#FFF8F3`).
- Gradient top container: `AppColors.surfaceVariant` (`#FFF2E0`) → `AppColors.background`.
- Text primary: `AppColors.textPrimary` (`#2A1A0A`).
- Text secondary: `AppColors.textSecondary` (`#5A4A4A`).
- Primary accent: `AppColors.primary` (`#9E003A`).
- Card selected background: `AppColors.selectedPink` (`#F8ECE9`).
- Card unselected background: `AppColors.peach` (`#FFE3B1`).
- Border selected color: `AppColors.borderSelected`.

## Shape & Radius
- Gradient container bottom radius: `AppRadius.xxl` (32).
- Cards (`_CheckoutMethodCard`) radius: `AppRadius.md` (12).
- Primary button radius via `DemoPrimaryButton` (now `AppRadius.md`).

## Components
- `DemoTopBar`
- `_CheckoutMethodCard`
- `DemoPrimaryButton`

## State
- Selected payment method stored in `order.paymentMethod`.
- Selected card shows radio‑button `Icons.radio_button_checked` (color `AppColors.primary`).
- Unselected shows `Icons.radio_button_off` (grey).
- Button enabled only when a method is selected.

## Exact Text
- Header in top bar: **Checkout**.
- Section title: **Payment Method**.
- Card titles: **QRIS**, **Virtual Account / E‑Wallet** (actual string in code: `QRIS` and `Virtual Account`).
- Card details:
  - QRIS: *Scan the QR code with your preferred e‑wallet or mobile banking app.*
  - Virtual Account: *Transfer to the virtual account number shown; the bank will confirm the payment.*
- Button label: **Bayar Sekarang**.

---
