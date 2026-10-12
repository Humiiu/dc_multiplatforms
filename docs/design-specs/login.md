# Login / Register Design Spec

## Layout
- Scaffold → SafeArea → Center → ConstrainedBox (maxWidth: 440)
- Vertical Column:
  1. Top spacing (`isCompact ? 14 : 48`).
  2. Logo (`AppLogo` size 110).
  3. Title **WELCOME** (style `AppTextStyles.welcome`, fontSize 28, color `AppColors.primaryDark`).
  4. Spacing 48.
  5. Tab container (height ~48) with two tabs **Login** and **Register** (selected tab has background `AppColors.secondary`, border radius 14).
  6. Spacing 34.
  7. If Register tab active, series of input fields:
     - Nama lengkap
     - Username
     - Kelas (dropdown)
     - Jurusan (dropdown)
     - Nomor telepon
     - Password (obscure toggle)
  8. Spacing 10 between each input.
  9. Primary button (`DemoPrimaryButton`) label **Daftar** (register) or **Sign In** (login).
 10. Bottom padding in scroll view: fromLTRB(28,28,28,24).

## Spacing & Padding
- Overall page padding: 28 left/right, 28 top, 24 bottom.
- Input field `contentPadding`: `EdgeInsets.fromLTRB(8,15,8,10)`.
- Underline borders: `AppColors.border` (normal), `AppColors.primary` (focused).
- Tab container padding: 4 all sides, border radius 14.

## Typography
- **WELCOME**: `AppTextStyles.welcome` (fontSize 28, weight bold, color `AppColors.primaryDark`).
- Input hint: `AppTextStyles.inputHint`.
- Input text: `AppTextStyles.inputText`.
- Button label: `AppTextStyles.buttonLarge`.

## Colors (hex)
- Background: default scaffold (no explicit, inherits `AppColors.background`).
- Tab selected background: `AppColors.secondary` (`#FFF0CA`).
- Tab unselected background: transparent.
- Text primary: `AppColors.textPrimary` (`#2A1A0A`).
- Text secondary (hint): `AppColors.textSecondary` (`#5A4A4A`).
- Primary button: background `AppColors.primary` (`#9E003A`), foreground white.

## Shape & Radius
- Buttons: border radius 8 (rounded to `AppRadius.md` = 12). Updated to `AppRadius.md`.
- Tab container: radius 14.
- Input underline: default border radius 0 (straight line).

## Components
- `AppLogo` (size 110).
- `_AuthTab` (custom widget for tabs).
- `_AuthInput` (TextField with underline).
- `_DropdownInput` (DropdownButtonFormField).

## State
- Tab selection toggles between Login and Register.
- Password field can be obscured (`_obscurePassword`).
- Button disabled when required fields empty (not implemented yet – mock).

## Exact Text
- Header: **WELCOME**
- Button labels: **Sign In** (login), **Daftar** (register).
- Input hints exactly as in code: “Nama lengkap”, “Username”, “Kelas”, “Jurusan”, “Nomor telepon”, “Password”.

---
