# Flutter Catering Booking App Enhancement Plan

Analysis and fix of bugs, design inconsistencies, and missing features in the catering booking application.

## User Review Required

> [!IMPORTANT]
> - The application uses **Riverpod** for state management.
> - **Firebase Realtime Database** is the backend.
> - **intl** package will be used for price formatting.
> - New files will be created for shared utilities and providers to improve code quality.

## Proposed Changes

### [Core & Shared Utilities]

#### [NEW] [price_formatter.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/utils/price_formatter.dart)
Create a consistent price formatting utility using the `intl` package.

#### [NEW] [string_extensions.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/extensions/string_extensions.dart)
Consolidate `capitalize()` and potentially `formatPrice` extensions here.

#### [NEW] [user_provider.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/providers/user_provider.dart)
Centralize `userDataProvider` to avoid duplicates and ensure consistent user data fetching.

#### [MODIFY] [constants.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/core/constants.dart)
Update `adminWhatsApp` with a clear TODO comment.

---

### [Bug Fixes]

#### [MODIFY] [home_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/home/home_page.dart)
- Remove duplicate `userDataProvider`.
- Fix typo: "Pesan Ketring" -> "Pesan Catering".
- Apply consistent price formatting.

#### [MODIFY] [profile_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/profile/profile_page.dart)
- Remove duplicate `userDataProvider`.
- Use the centralized provider.

#### [MODIFY] [checkout_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/checkout/checkout_page.dart)
- Remove duplicate `StringExtension`.
- Apply consistent price formatting.

#### [MODIFY] [history_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/history/history_page.dart)
- Remove duplicate `StringExtension`.
- Apply consistent price formatting.

---

### [Design & Feature Enhancements]

#### [MODIFY] [history_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/history/history_page.dart)
- Header: Show User Name instead of "Riwayat Pesanan".
- Tabs: Add "Semua | Lunas | Hutang" pill filters.
- Badges: Add status badges (Hutang=yellow, Lunas=green, Terlambat=red).
- Summary: Add "Total Pembayaran" at the bottom.

#### [MODIFY] [profile_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/profile/profile_page.dart)
- Header: Update to include large Avatar, Name, Username, and "Pelanggan Setia" badge.
- QRIS Section: Add QRIS section with bank selection (BCA, BRI, etc.) and Payment Code.

#### [MODIFY] [home_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/home/home_page.dart)
- Styling: Improve "SISA TAGIHAN" card with gradient and shadow.
- Notification: Add badge count to the notification bell.

#### [MODIFY] [checkout_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/checkout/checkout_page.dart)
- QR Code: Integrate `qr_flutter` to generate real QRIS codes.

#### [MODIFY] [order_page.dart](file:///C:/Users/ASUS/AndroidStudioProjects/dc_multiplatforms/lib/screens/order/order_page.dart)
- Images: Replace icon placeholders with better placeholders or skeletons.
- Styling: Ensure consistent Maroon (#9E003A) accents.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions in models/logic.
- Verify price formatting with unit tests for `PriceFormatter`.

### Manual Verification
- Visual inspection of all screens against Figma references (`login.png`, `home.png`, etc.).
- Verify QR code generation on the Checkout page.
- Test History page filters and status badges.
- Check responsive behavior on different screen sizes.
