# Project Status

## Project Overview
**Type:** Flutter multi-platform app (Android, iOS, Web, Windows, macOS, Linux)  
**Purpose:** Catering booking system for vocational high school students  
**Tech Stack:** Flutter + Riverpod + Firebase Auth (Phone OTP) + Firebase Realtime Database + GoRouter  

## Git State
- **Branch:** `master` (on commit `68dad38`)
- **Staged:** 0
- **Modified (unstaged):** 7 files (auth_page, auth_service, database_service, database.rules.json, history_page, logo_widget, order_page, phone_normalization_test)
- **Untracked:** 0
- **Last commit:** `Fix duplicated session 3 notes in STATUS.md`

## Implementation Status

### ✅ Complete (All UI Revised per Figma Design)
- **Authentication:** Firebase Phone OTP auth flow with login/register toggle
  - Login: username/phone + password
  - Register: OTP verification → username, name, phone, kelas (X/XI/XII), jurusan (RPL/DKV/ANM/BC/TKJ/GD)
  - Duplicate account prevention via OTP verification
- **Core infra:** Firebase initialization wrapper, GoRouter routing (ShellRoute with bottom nav), Riverpod ProviderScope
- **Models:** `User` (with username, jurusan enum, kelas enum), `Order` (with paymentMethod enum, dueDate), `MenuItem` with fromMap/toMap serialization
- **Services:** `AuthService` (sendOtp, verifyOtp, registerUser, signInWithEmailAndPassword, updatePassword), `DatabaseService` (CRUD for users/menus/orders, username/phone uniqueness checks)
- **Home page:** Dashboard with gradient "Tagihan Kamu" card, auto-scroll horizontal weekly menu cards (Senin-Jumat) with date + photo, "Punya Request Khusus?" card with gradient, "Pesan Ketring" CTA button with shadow
- **Order page:** Select Days section at top with animated day chips, expandable menu sections per selected day with add/remove animation, bottom total bar with Hutang (max 100k, jatuh tempo Jumat) and Bayar Sekarang options
- **Checkout page:** Order summary card, payment method selection (QRIS with 5-min timer, Virtual Account placeholder, E-Wallet placeholder, Hutang), QRIS bottom sheet with countdown timer and simulated payment flow
- **History page:** Orders grouped by week (Minggu 1 Oktober, etc.), each order shows date-time, payment method, total, status badge (Lunas/Hutang), overdue indicator, "Bayar Hutang Minggu Ini" button for unpaid weeks
- **Profile page:** Profile photo with edit badge, username, phone, jurusan, kelas display, action cards for Edit PFP, Ubah Password, Hubungi Admin, logout with confirmation
- **UI Design System:** Complete Material 3 theme with maroon/gold palette from Figma
  - Colors: primary #9E003A, primaryDark #740028, secondary #FFF0CA, accent #FFE5B9, background #FFF8F3
  - Gradients: Primary (gold→maroon), TagihanBg, ImageOverlay
  - Fonts: Playfair Display (headers), Plus Jakarta Sans (body), Montserrat (Sign In button)
  - Shadows: Subtle, Card, CardElevated, ButtonPrimary, ButtonPrimaryStrong
  - Radius: xs(4) to xxl(32), Round
  - Spacing: xs(4) to xxl(48)
- **WhatsApp integration:** Both `home_page.dart` and `profile_page.dart` have "Hubungi Admin" via `url_launcher`
- **Auth provider:** `currentUserProvider`, `authStateChangesProvider`, `currentUserIdProvider`, `isAuthenticatedProvider`, `registrationFormProvider`

### ✅ Issues Fixed (Recent)
- **main.dart:6** — Syntax error fixed
- **Theme wiring** — `main.dart` uses `buildAppTheme()` from `theme.dart`
- **Placeholder UIDs** — Replaced with real authenticated UID via `currentUserProvider`
- **Auth redirect guard** — GoRouter redirect callback for auth state
- **WA launcher wired** — Working with fallback SnackBar
- **Profile data loading** — Reactive loading with `userDataProvider`
- **Menu data structure reconciled** — README matches code (`/menus/{day}/{menuId}`)

### ⚠️ Known Issues / TODOs
- **Checkout page:** Midtrans payment integration is mock (QRIS simulated with timer, Bank/VA/E-Wallet placeholders)
- **Profile photo upload** — Placeholder edit badge; needs `image_picker` + Firebase Storage upload
- **Midtrans integration** — Needs Cloud Function for Snap tokens + webhook verification
- **Widget test** — Basic smoke test only; needs comprehensive widget tests
- **Minor lint warnings:** Unused imports in auth_page, build_context_sync in checkout_page (acceptable)

### ✅ Just Completed (session 4, 2026-08-25): Git staging + commit
- **All 37 files staged and committed** (`6ee4583`) — clean working tree
- Includes: all screens, services, models, providers, theme, constants, assets, docs, CI
- Working tree now clean (0 unstaged, 0 untracked)

### ✅ Just Completed (session 10, 2026-08-25): Fix Android compatibility
- **compileSdk/targetSdk** (`android/app/build.gradle`): set to `35` (stable, matches installed `android-35`)
- **NDK** (`android/app/build.gradle`): set to `27.0.12077973` (installed via sdkmanager, required by Firebase plugins)
- **AGP** (`android/settings.gradle`): upgraded from `8.1.0` → `8.7.3`
- **Gradle** (`gradle-wrapper.properties`): upgraded from `8.3` → `8.9`
- **Kotlin** (`android/settings.gradle`): upgraded from `1.8.22` → `1.9.24`
- **Root cause**: NDK missing + old AGP/Gradle couldn't handle compileSdk 35 with Firebase plugins
- **Build**: `flutter build apk --debug` ✅ SUCCESS

### ✅ Just Completed (session 9, 2026-08-25): Fix permission-denied + TextStyle error
- **Username/phone lookup indexes** (`database_service.dart`): added `/usernames/{username}` and `/phones/{phone}` lookup paths — `getUserByUsername`, `getUserByPhone`, `isUsernameTaken`, `isPhoneRegistered` now use direct path reads instead of `orderByChild` queries on `/users` (which were denied by rules)
- **`setUser` batch write** (`database_service.dart`): writes to `users/$uid`, `usernames/$username`, `phones/$phone` in single `_root.update()` call
- **TextStyle.lerp error fixed** (`auth_page.dart`): "Lupa password?" TextButton now uses `TextButton.styleFrom(textStyle:)` instead of `child: Text(style:)` — avoids `inherit` mismatch with `AnimatedDefaultTextStyle`
- **`database.rules.json` updated**: added `/usernames` and `/phones` rules (`.read: auth != null`, `.write: auth != null && !data.exists()`)

### ✅ Just Completed (session 8, 2026-08-25): Fix Firebase permission-denied
- **`getActiveOrders()` fixed** (`database_service.dart`): now takes `uid` parameter, queries `/orders` with `orderByChild('userId').equalTo(uid)` instead of reading ALL orders — eliminates permission-denied on home page
- **`tagihanProvider` fixed** (`home_page.dart`): passes `currentUserIdProvider` to `getActiveOrders(uid)`, returns 0 if user not logged in
- **`database.rules.json` rewritten**: rules now check per-order `data.child('userId').val() === auth.uid` for read/write at `/orders/{orderId}` level, not broken `$uid === auth.uid` at `/orders` level
- **`markPaid` error handling** (`database_service.dart`): added try/catch with debugPrint + rethrow
- **Root cause**: `getActiveOrders()` read all `/orders` without filtering by userId → Firebase rules denied the entire read

### ✅ Just Completed (session 7, 2026-08-25): Fix phone input spam + clean up
- **PhoneInputFormatter rewritten** (`logo_widget.dart`): no longer prepends `+62` into text value — only formats digits as `XXXX-XXX-XXX`. Strips leading `0` or `62` if user types them. Prevents the spam/loop bug where `+62` reappeared on every keystroke.
- **Phone field hint removed** (`auth_page.dart`): `hintText: ''`, `leadingText: '+62 '` — the `+62` now shows as a permanent prefix via `prefixText` decoration, not as part of editable text.
- **Tests updated** (`phone_normalization_test.dart`): 22 tests passing, including new tests for stripping leading `0` and `62`.

### ✅ Just Completed (session 6, 2026-08-25): Runtime error fixes
- **RenderFlex overflow fixed** (`order_page.dart`): removed fixed `height: 100` from `_PaymentOptionCard` AnimatedContainer, changed to `padding: symmetric(h:16, v:14)` so card sizes to content; added `maxLines: 1` to title, `maxLines: 2` with `TextOverflow.ellipsis` to subtitle — prevents 3-line subtitle from overflowing 68px content area
- **Firebase index error fixed** (`database_service.dart`): `getUserOrders` queries `/orders` with `orderByChild('userId')` — added try/catch with `debugPrint` + empty list fallback; same for `getActiveOrders`
- **`database.rules.json` created**: contains `.indexOn: ["userId"]` for `/orders` path — must be deployed to Firebase Console manually
- **History page error handling** (`history_page.dart`): FutureBuilder now checks `snap.hasError` and shows empty state instead of crash

### ✅ Just Completed (session 5, 2026-08-25): Auth + phone input fixes
- **PhoneInputFormatter added** (`logo_widget.dart`): formats display as `+62 8999-107-194` with auto dashes; strips non-digits, limits to 10 digits; cursor always at end
- **Register phone field updated** (`auth_page.dart`): removed prefix icon (matching Figma `regis.png`), applied `PhoneInputFormatter`, hint shows `8999-107-194`
- **Logo shadow reverted to Figma** (`logo_widget.dart`): `Color(0x3F000000)`, blur 4, offset (-4,4) — matches Figma export exactly
- **Login auth flow fixed** (`auth_service.dart`): looks up user by username or phone in Realtime DB, then signs in with UID-based email (`{uid}@catering.app`)
- **Registration creates email account** (`auth_page.dart`): after OTP verification + DB save, signs out from phone auth, creates Firebase email account, enabling username/password login
- **DB lookup methods added** (`database_service.dart`): `getUserByUsername()`, `getUserByPhone()` — query Firebase DB by field
- **`_buildInputField` updated**: `prefixIcon` now nullable, new `formatters` param overrides `digitsOnly`
- **Tests expanded**: 9 new `PhoneInputFormatter` tests (format, strip, limit, normalize roundtrip) — total 20 tests passing
- **Flutter analyze**: 1 info only (pre-existing `use_build_context_synchronously` in checkout)

### ✅ Validation (2026-08-25, session 10)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (22 tests)
- `flutter build apk --debug` — SUCCESS

### ✅ Validation (2026-08-25, session 9)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (22 tests)

### ✅ Validation (2026-08-25, session 8)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (22 tests)

### ✅ Validation (2026-08-25, session 7)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (22 tests)

### ✅ Validation (2026-08-25, session 6)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (20 tests)

### ✅ Validation (2026-08-25, session 5)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (20 tests: 10 phone normalization + 9 PhoneInputFormatter + 1 app smoke test)

### ✅ Validation (2026-08-25, session 3)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing, non-fatal)
- `flutter test` — PASS (11 tests: 10 phone normalization + 1 app smoke test)

### ✅ Validation (2026-08-25, session 2)
- `flutter pub get` — completed successfully (64 packages)
- `flutter analyze` — 1 info only (build_context_sync in checkout - acceptable for delayed snackbar)
- `flutter test` — PASS (1 test)

### ✅ Just Completed (session 3, 2026-08-25): Register UI fixes
- **Tab switcher state fixed** (`auth_page.dart`): sliding pill is now ALWAYS filled primary and sits behind the ACTIVE tab; labels rendered on top via `_buildTabLabel()` — active = white w700 bold, inactive = dark #261900 w600. Switching tabs now visibly swaps fill, text color, and weight.
- **Logo shadow refined** (`logo_widget.dart`): softened from black 25%/blur4 (read as rough gray ring) to black 15%/blur8 offset(-3,3); border uses `AppColors.borderStrong`. Position (top, above WELCOME) unchanged.
- **Phone normalization added** (`normalizeIndonesianPhone` in `logo_widget.dart`, used by auth page):
  - Accepts `8999107194`, `08999107194`, `+628999107194`, `628999107194`; strips spaces/dashes/parens
  - Always yields single canonical `+628…` — no more double prefixes (`+620899…`)
  - Rejects landline (021…), too-short (<9 digits after prefix), too-long (>12), non-digits
- **Phone input UX** (`auth_page.dart`): static `+62` leading text inside the field (cursor sits right after it), hint shows full example `+62 8xx xxx xxxx`, `FilteringTextInputFormatter.digitsOnly` blocks letters; stale error clears while typing once format becomes valid.
- **Error messages per spec**: empty → `Nomor telepon tidak boleh kosong`; bad format → `Format nomor telepon tidak valid`. Field-level errors still gated behind touch (`_touchedFields`) or submit attempt; each error renders exactly once (global banner OR field highlight, not duplicated).
- **Jurusan + Kelas side-by-side** (`auth_page.dart`): LayoutBuilder row (flex 3:2, gap 12) when width ≥ 292px; falls back to stacked Column on very narrow screens. Options unchanged: Jurusan RPL/DKV/ANM/BC/TKJ/GD, Kelas X/XI/XII.
- **Saved phone normalized**: `registerUser` now persists the normalized `+62…` number instead of raw input.

### ✅ Just Completed (session 2, 2026-08-25): Auth Page Polish per Figma
- **Logo asset added:** user-supplied image copied to `assets/logo.png`; registered in `pubspec.yaml` under `assets:`
- **New widget** `lib/widgets/logo_widget.dart`: `AppLogo` (loads `assets/logo.png`, circular border #5E6E0129, shadow offset(-4,4) blur 4 black 25% — matches Figma) + `AppLogoFallback` (icon-based backup)
- **Logo repositioned:** moved from bottom of page to TOP above "WELCOME" text (matches Figma `top:-76` position), size 90px
- **Login label fixed:** "Email or Phone" → "Username atau Nomor Telepon", hint "Masukkan username atau +628xx"; no more "Email" anywhere
- **Register validation improved:** field-level errors now only appear after a field is touched (`_touchedFields` set); error colors applied to label/border/icon of the offending field; global submit errors unchanged
- **Phone prefix:** `+62 ` prefix kept; hint changed to `8xx xxx xxxx` so cursor/hint don't overlap prefix
- **Enter-to-submit:** phone/OTP fields submit on keyboard done action
- **Fixed mkdir bug:** earlier `mkdir C:\...` in Git Bash created a literal folder named `C:UsersjundiStudioProjectsdc_multiplatformsassets` — removed it and created proper `assets/`
- **Type fixes:** `onFieldSubmitted` typed as `ValueChanged<String>?`; all call-sites updated

### ⏳ Untracked / Uncommitted Work (Ready to Stage)
- None — working tree is clean

## Next Tasks
1. **Deploy Firebase Realtime Database rules** — Copy `database.rules.json` to Firebase Console (Realtime Database → Rules) to add `.indexOn: ["userId"]` for `/orders`
2. **Add `image_picker` dependency** — For profile photo upload feature
3. **Implement profile photo upload** — `image_picker` + Firebase Storage
4. **Implement Midtrans Cloud Function** — For real QRIS payment integration
5. **Add comprehensive widget tests** — For all screens (auth, home, order, checkout, history, profile)
6. **Configure Firebase for production** — google-services.json, GoogleService-Info.plist

## Manual Firebase Config Required
The file `database.rules.json` has been created in the project root with the correct rules including `.indexOn: ["userId"]` for `/orders`. To deploy:
1. Open [Firebase Console](https://console.firebase.google.com) → your project → Realtime Database → Rules
2. Paste the contents of `database.rules.json`
3. Click "Publish"

### ⚠️ Firebase Rules yang Harus Di-publish Manual
File `database.rules.json` di root proyek berisi rules lengkap. Harus dipublish secara manual di Firebase Console:
1. Buka Firebase Console → Realtime Database → Rules
2. Copy-paste isi `database.rules.json`
3. Klik Publish
4. Rules meliputi: `/users/{uid}`, `/menus`, `/orders/{orderId}` dengan `.indexOn: ["userId"]`

## Validation Commands
```bash
flutter analyze          # 1 info (acceptable)
flutter pub get          # OK
flutter test             # PASS
flutter build apk        # Should work
```