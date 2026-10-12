# Profile Design Spec

## Layout
- Scaffold → SafeArea(bottom: false) → ListView (padding fromLTRB 28,46,28,24).
- Children (vertical):
  1. Centered avatar placeholder container (124 dp square) with border radius 14, background `AppColors.surfaceVariant`, border color `#E8DADA`. Inside an `Icon(Icons.person)` (size 82, color `AppColors.textSecondary`).
  2. SizedBox(height: 16).
  3. Text **Humiiu** (style `AppTextStyles.welcome`, fontSize 28, color `AppColors.textPrimary`).
  4. SizedBox(height: 8).
  5. Row with two `_ProfileTag` chips:
     - **Class XII IPS 2**
     - **Major: MIPA**
     (spacing 8 between tags).
  6. SizedBox(height: 14).
  7. Text phone string **0899-XXXX-XXXX** (style `AppTextStyles.bodyLarge`, color `AppColors.textSecondary`).
  8. SizedBox(height: 42).
  9. Three `_ProfileAction` cards stacked vertically with 14 dp spacing:
     * **Edit Profile** (icon `Icons.edit_outlined`, background color `#A40B42`).
     * **Ubah Password** (icon `Icons.lock_outline`, background color `AppColors.gold`).
     * **Hubungi Admin** (icon `Icons.headset_mic_outlined`, background color `#9B0053`).
    Each action displays title, subtitle, and a trailing chevron icon.
 10. SizedBox(height: 36).
 11. Centered `TextButton.icon` **Logout** (icon `Icons.logout`, color `AppColors.error`).

## Spacing & Padding
- Overall page padding: 28 left/right, 46 top, 24 bottom.
- Avatar container size 124 dp with inner `Icon` 82.
- Chip padding: horizontal 12, vertical 5, radius 20.
- Action card background: `Color(0xFFFFEBCD)` with border radius 12, internal padding 16.
- Bottom logout button has default TextButton padding.

## Typography
- User name **Humiiu**: `AppTextStyles.welcome` (fontSize 28, color `AppColors.textPrimary`).
- Phone number: `AppTextStyles.bodyLarge` (color `AppColors.textSecondary`).
- Chip label: `AppTextStyles.caption`.
- Action titles: `AppTextStyles.bodyMediumBold`.
- Action subtitles: `AppTextStyles.bodySmall` (fontSize 13).
- Logout button label: default button style `AppTextStyles.bodyMediumBold`.

## Colors (hex)
- Background: `AppColors.background` (`#FFF8F3`).
- Avatar background: `AppColors.surfaceVariant` (`#FFF2E0`).
- Icon color inside avatar: `AppColors.textSecondary` (`#5A4A4A`).
- Name text: `AppColors.textPrimary` (`#2A1A0A`).
- Chip background: `#FFFFDEA5`.
- Chip text: `AppTextStyles.caption` (default color).
- Action card background: `#FFFFEBCD`.
- Action icon background colors:
  * Edit Profile: `#A40B42`.
  * Ubah Password: `AppColors.gold` (`#FECF15`).
  * Hubungi Admin: `#9B0053`.
- Action icon color: white.
- Logout text/icon color: `AppColors.error` (`#BA1A1A`).

## Shape & Radius
- Avatar container radius 14.
- Chip radius 20.
- Action card radius 12.
- Buttons use `DemoPrimaryButton` radius (`AppRadius.md`).

## Components
- `AppLogo` (used elsewhere, not on this page).
- `_ProfileTag` (custom chip).
- `_ProfileAction` (custom card with icon, title, subtitle).
- `DemoPrimaryButton` (used for actions in other screens).
- `DemoTopBar` is not used on this page.

## State
- No dynamic state in mock UI; actions trigger demo dialogs (`_showDemoDialog`) or admin WhatsApp sheet.

## Exact Text
- Avatar placeholder icon is literal `Icons.person`.
- Name: **Humiiu**.
- Class tag: **Class XII IPS 2**.
- Major tag: **Major: MIPA**.
- Phone: **0899-XXXX-XXXX**.
- Action titles & subtitles:
  * **Edit Profile** – *Update your personal information*.
  * **Ubah Password** – *Secure your account*.
  * **Hubungi Admin** – *Get help with your orders*.
- Logout button label: **Logout**.

---
