# Project Status

## Project Overview
**Type:** Flutter multi-platform app (Android, iOS, Web, Windows, macOS, Linux)  
**Purpose:** Catering booking system for vocational high school students  
**Tech Stack:** Flutter + Riverpod + Firebase Auth (Phone OTP) + Firebase Realtime Database + GoRouter  

## Git State
- **Branch:** `master` (on commit `e1e23f9`)
- **Staged:** 0
- **Modified (unstaged):** 3 (STATUS.md, profile_page.dart, pubspec.yaml)
- **Untracked:** 1 (image_upload_service.dart)
- **Last commit:** `e1e23f9 ai pler`

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
- **Profile page:** Profile photo with edit badge, username, phone, jurusan, kelas display, action cards for Ganti Foto Profil (gallery/camera picker → Firebase Storage upload → DB update), Ubah Password, Hubungi Admin, logout with confirmation
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
- **Profile photo upload** — UI wired up and functional on mobile/desktop; web shows "belum tersedia" (dart:io limitation)
- **Midtrans integration** — Needs Cloud Function for Snap tokens + webhook verification
- **Widget test** — Basic smoke test only; needs comprehensive widget tests
- **Minor lint warnings:** Unused imports in auth_page, build_context_sync in checkout_page (acceptable)

### ✅ Just Completed (session 4, 2026-08-25): Git staging + commit
- **All 37 files staged and committed** (`6ee4583`) — clean working tree
- Includes: all screens, services, models, providers, theme, constants, assets, docs, CI
- Working tree now clean (0 unstaged, 0 untracked)

### ✅ Just Completed (session 11, 2026-08-26): Profile photo upload — wired up
- **`image_upload_service.dart` created**: picks image (gallery/camera) via `image_picker`, uploads to Firebase Storage at `profile_photos/{uid}.jpg`, returns download URL. `kIsWeb` guard prevents `dart:io` File calls on web.
- **`profile_page.dart` updated**: "Ganti Foto Profil" button now shows source picker bottom sheet → uploads → saves `photoUrl` to DB via `updateUser()` → invalidates `userDataProvider` → shows success SnackBar. Loading spinner shown during upload. Web shows "belum tersedia" message.
- **`_ActionCard` widget updated**: `onTap` nullable, new `trailing` param (used for loading spinner instead of chevron).
- **Removed unused `dart:io` import** from `profile_page.dart` (was causing warning).
- **Dependencies already present**: `image_picker: ^1.0.7`, `firebase_storage: ^11.6.0` in `pubspec.yaml`.
- **`AppUser.photoUrl`** field already in model + `toMap`/`fromMap`/`copyWith`.

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

### ✅ Validation (2026-08-26, session 11)
- `flutter analyze` — 1 info only (`use_build_context_synchronously` in checkout, pre-existing)
- `flutter test` — PASS (22 tests)

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
- `lib/services/image_upload_service.dart` — new file (profile photo upload service)
- `lib/screens/profile/profile_page.dart` — modified (wired up photo upload)
- `pubspec.yaml` — modified (`image_picker`, `firebase_storage` deps added)
- `STATUS.md` — modified (this session)

### ✅ Just Completed (session 13, 2026-08-27): ULTIMATE Bug Hunt & Cleanup
- **Architectural Cleanup:**
  - **Shared Providers**: Created `lib/providers/user_provider.dart` and `lib/providers/order_provider.dart` to consolidate duplicated logic and facilitate state invalidation across screens.
  - **Checkout Refactor**: Created `lib/providers/checkout_provider.dart` and `lib/models/cart_item.dart`. `CheckoutPage` now supports both new orders and paying off existing debt (Hutang) from the dashboard or history.
- **Bug Fixes:**
  - **Auth Robustness**: `AuthPage` now deletes the Firebase Auth account if Realtime DB registration fails, preventing orphaned accounts.
  - **Memory Leaks**: Added `controller.dispose()` in `ProfilePage` password change dialog.
  - **State Invalidation**: Create/Pay operations now properly trigger `ref.invalidate()` for `tagihanProvider` and `ordersProvider`, ensuring the UI reflects changes immediately.
  - **Async/Context Guards**: Added `context.mounted` checks to all async callbacks to satisfy `use_build_context_synchronously` lint and prevent crashes.
  - **Data Safety**: Models now handle invalid/null data gracefully with fallbacks (e.g., bad Jurusan/Kelas/PaymentMethod).
- **Purge Unused Items:**
  - Removed unused dependencies: `cloud_functions`, `cached_network_image`.
  - Removed unused providers: `authStateChangesProvider`, `isAuthenticatedProvider`, `registrationFormProvider`.
  - Cleaned up unused imports and variables across the entire project.
- **UI/UX Polish:**
  - Added loading indicator to Hutang confirmation in `OrderPage`.
  - Moved hardcoded error strings to `AppConstants`.
  - Fixed Tagihan payment flow: "Bayar Sekarang" from dashboard now correctly loads unpaid orders into checkout.

### ✅ Just Completed (session 14, 2026-08-30): Web + Admin Panel
- **Role system added** (`lib/models/user.dart`): new `UserRole` enum (`user`/`admin`) with extension + `AppUser.role` field, `isAdmin` getter, full fromMap/toMap/copyWith serialization (defaults to `user`).
- **Admin DB queries** (`lib/services/database_service.dart`): `getAllOrders()`, `getAllUsers()`, `updateOrderPaidStatus(orderId, isPaid)` (toggles `isPaid` + `paidAt`), `deleteMenuItem(day, menuId)`. `markPaid()` now also writes `paidAt`.
- **Admin providers** (`lib/providers/admin_provider.dart`): `currentUserRoleProvider`, `isAdminProvider`, `adminOrdersProvider`, `adminUsersProvider`, `adminMenuProvider`, plus an `AdminRoleCache` for the sync route guard.
- **Global Riverpod container** (`lib/main.dart`): created `appContainer` + `UncontrolledProviderScope` so the GoRouter redirect can read admin role synchronously.
- **Routing** (`lib/router.dart`): added `/admin/{dashboard,menu,orders,users}` under an `AdminShell`; redirect route-guard sends non-admin users to `/home`.
- **Admin Shell** (`lib/screens/admin/admin_shell.dart`): desktop (≥900px) shows fixed left sidebar + content; small screens use AppBar + bottom NavigationBar.
- **Admin pages** (`lib/screens/admin/`):
  - `admin_dashboard_page.dart`: stat cards (pendapatan masuk, utang aktif, total pesanan, pesanan hari ini) + recent orders list.
  - `admin_menu_page.dart`: weekly menu CRUD (day selector chips, add/edit/delete item dialog with name/price/image URL).
  - `admin_orders_page.dart`: all-orders table (desktop) / cards (mobile), Lunas-Hutang filter, per-order paid toggle.
  - `admin_users_page.dart`: student list/table with per-user active-debt (non-admin only).
- **Profile entry point** (`lib/screens/profile/profile_page.dart`): "Panel Admin" card shown only when `isAdminProvider` → navigates to `/admin/dashboard`.
- **Firebase rules** (`database.rules.json`): admins can read all `/users`, write `/menus`, and read/write all `/orders`; regular users unchanged. (Must be deployed to Firebase Console.)
- **Tests** (`test/user_role_test.dart`): 11 new tests for `UserRoleExtension` + `AppUser` role serialization.

## Next Tasks
1. **Deploy Firebase Realtime Database rules** — Copy updated `database.rules.json` to Firebase Console (Realtime Database → Rules). ⚠️ The admin additions only work AFTER this is deployed.
   *(in-progress web refactor: `lib/screens/web_shell.dart` top-nav + `lib/utils/formatters.dart` shared helpers now wired and compiling.)*
2. **Promote a user to admin** — In Firebase Realtime DB set `users/{uid}/role` = `"admin"` for the catering manager account.
3. **Run the web-first handoff** — Hand `GEMINI_WEB_HANDOFF.md` to Gemini to (a) build a bespoke web-user layout (top-nav shell on desktop, bottom-nav on phone browser), (b) verify/complete the admin panel, and (c) finish cleanup + optimization.
4. **Midtrans Cloud Function** — For real QRIS payment integration.
5. **Add comprehensive widget tests** — For all screens (auth, home, order, checkout, history, profile, admin).

## Validation Commands
```bash
flutter analyze          # 0 errors, 0 warnings
flutter test             # PASS (32 tests)
flutter build apk --debug # Mobile build should succeed
flutter build web --release # Web build → build/web ✅
```

### ✅ Just Completed (session 17, 2026-08-30): Web-First UX + Final Polish
- **Responsive Layout** (`lib/screens/web_shell.dart`): built a top-nav shell for desktop (>=900px) with centered max-width content area (1200px) and a "Panel Admin" shortcut; mobile browsers continue using the bottom-nav `MainShell`.
- **Airtight Admin Guard** (`lib/providers/admin_provider.dart`, `lib/router.dart`): refactored `AdminRoleCache` to a `ChangeNotifier` and wired it as a `refreshListenable` to `GoRouter`. The guard now waits for user data to load on refresh instead of bouncing admins to `/home`.
- **Shared Utilities** (`lib/utils/formatters.dart`): centralized `rupiah`, `date`, and `dateTime` formatting to eliminate logic duplication across admin and user pages.
- **Improved UX** (`lib/widgets/error_widget.dart`): added a consistent `AppErrorWidget` with a "Coba Lagi" (Retry) button, integrated into Home, History, and all Admin pages for better failure recovery.
- **Web Niceties**:
  - Enabled **Path URL Strategy** (`lib/utils/configure_web.dart`): removed the `#` from browser URLs.
  - Updated `index.html` and `manifest.json`: refined meta descriptions, PWA colors, and app titles.
  - Fixed `ImageUploadService`: added web support using `readAsBytes()` + `putData()` for profile photos.
- **Cleanup**: removed the empty `scratch/` directory and confirmed all 32 tests pass with 0 analyzer issues.

## Next Tasks
1. **Promote a user to admin** — In Firebase Realtime DB set `users/{uid}/role` = `"admin"`.
2. **Midtrans Cloud Function** — For real QRIS payment integration.
3. **Comprehensive widget tests** — For all screens including admin and responsive shells.

## Validation Commands
```bash
flutter analyze          # 0 issues
flutter test             # 32 pass
flutter build web        # Build successful
```

### ✅ Just Completed (session 15, 2026-08-30): Cleanup + Gemini Web-First Handoff
- **Deleted 5 dead/seed/dump files** (user-confirmed):
  - `siswa.json` — UTF-16 export dump of student DB records (one-time migration source)
  - `menus.json` — seed dump of `/menus`
  - `init_db.json` — seed dump (same as menus, plus users/orders blocks)
  - `scratch/migrate_siswa.dart` — one-time migration script reading `siswa.json`
  - `settings.json` — unused manual config; `hargaKetringDefault`/`maxUtang` are hardcoded in `AppConstants`
  - Verified: nothing in `lib/` referenced any of these. Removed from git index too (`scratch/` dir now empty).
- **Created `GEMINI_WEB_HANDOFF.md`** — a full autonomous handoff prompt telling Gemini to:
  - Build a **bespoke web-first user layout** (top-nav web shell on desktop, bottom-nav mobile shell on phone browsers; reuse existing screens/providers; PWA + deep-linking niceties).
  - **Verify/complete the admin panel** and make the role guard airtight.
  - **Continue cleanup** (unused deps like `intl`, empty dirs, dead scripts).
  - **Optimize** (shared `_rupiah`/date helper, loading/error/retry states, string constants, query notes).
  - Keep `flutter analyze`=0, tests green, and both web + apk building.
- **Validation**: `flutter analyze` → **No issues found** (the 3 pre-existing `info` in scratch/ are gone with the deleted file). `flutter test` → **32 pass**. `flutter build web --release` ✅. `flutter build apk --debug` ✅.

### ✅ Just Completed (session 14, 2026-08-30): Web + Admin Panel
