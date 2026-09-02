# 🕸️ Gemini Web-First Handoff — Catering Booking: Full Web Experience + Admin + Optimization

You are an **AUTONOMOUS Senior Flutter + Firebase Engineer**. Your job is to turn this Flutter catering booking app into a **first-class, browser-based product**: a student should be able to open the web app in Chrome/Safari on any phone and book catering immediately — no app install required — AND keep the existing Android/iOS app working perfectly.

You have **FULL AUTONOMY**: make changes directly, fix bugs immediately, and delete dead code. The only hard constraints are the SAFEGUARDS in **Section 7** (never leave the build broken or tests failing).

---

## ENVIRONMENT & ARCHITECTURE (source of truth)

- **Working directory**: `C:\Users\jundi\StudioProjects\dc_multiplatforms` (work ONLY inside this folder)
- **Framework**: Flutter 3.6+ / Dart, Material 3. Palette: Maroon `#9E003A`, Gold/cream `#FFF0CA`, background `#FFF8F3`; fonts Playfair Display (headers) / Plus Jakarta Sans (body). All tokens are in `lib/core/theme.dart` + `lib/core/constants.dart`.
- **State**: Riverpod (`flutter_riverpod`).
- **Auth**: Firebase Auth — email/password with UID-based email `<uid>@catering.app`. Login = phone/username lookup → UID-email sign-in.
- **DB**: Firebase Realtime Database `https://dc-prototype-1-117ab-default-rtdb.firebaseio.com`.
- **Storage**: Firebase Storage (`profile_photos/{uid}.jpg`).
- **Routing**: GoRouter — see `lib/router.dart`.

### Database structure (do not change without updating `database.rules.json`)
| Path | Purpose |
|------|---------|
| `/users/{uid}` | User profile (has `role`: `"user"` \| `"admin"`) |
| `/usernames/{username}` | `{uid}` lookup index |
| `/phones/{phone}` | `{uid}` lookup index |
| `/menus/{day}/{menuId}` | Weekly menu, day lowercase (senin..jumat) |
| `/orders/{orderId}` | Orders; `.indexOn: ["userId"]` |

`database.rules.json` already lets **admins** read all users/orders + write menus; regular users only read/write their own data.

### Existing folders you will work with
- `lib/screens/` — `auth/`, `home/`, `order/`, `checkout/`, `history/`, `profile/`, `admin/` (admin shell + dashboard/menu/orders/users pages already built)
- `lib/screens/main_shell.dart` — mobile bottom-nav shell
- `lib/providers/` — `auth_provider`, `user_provider`, `order_provider`, `checkout_provider`, `admin_provider` (incl. `AdminRoleCache` for the sync route guard)
- `lib/router.dart` — routes incl. `/admin/*` guarded by role

---

## SECTION 1 — WEB-FIRST USER EXPERIENCE (★ top priority)

The website must be a **real, user-facing site** — not just the mobile app stretched wide. A student in a hurry opens the URL, taps a few times, and books catering.

### A. Responsive shell / layout
- Create `lib/screens/web_shell.dart` (or similar) used for the **user** pages.
  - **≥ ~900px width** (desktop/laptop web): a **top navigation bar** (brand/logo + links: *Beranda, Pesan, Riwayat, Profil*; and *Panel Admin* shown only when `isAdminProvider` is true). Content centered in a `maxWidth ≈ 1200px` container. Use responsive grid cards instead of fixed full-width columns.
  - **< 900px width** (phone browser): reuse the existing bottom-nav `MainShell` so phone users in a browser get the familiar app feel.
- **Reuse ALL existing screens/providers** (`home_page.dart`, `order_page.dart`, `history_page.dart`, `checkout_page.dart`, `profile_page.dart`). Do **NOT** duplicate business logic — only wrap them in the responsive shell and constrain width.
- Wire the shell into `lib/router.dart` so desktop web and mobile both work from the same routes.

### B. Web niceties (make it feel native in a browser)
- Correct browser tab **title** and a proper meta description per page.
- **PWA-ready**: web manifest + service worker; offline shell for the static assets. (Enable/verify via `web/manifest.json` + `web/index.html`.)
- **Deep linking**: verify `/home`, `/order`, `/checkout`, `/history`, `/profile`, `/admin/*` load directly by URL.
- **Responsive images & tap targets**: menu images must not overflow; tappable areas ≥ 44px on touch.
- Fast first paint: keep initial load lean.

---

## SECTION 2 — ADMIN PANEL (already scaffolded — finish & verify)

The admin screens exist under `lib/screens/admin/` and are routed at `/admin/dashboard`, `/admin/menu`, `/admin/orders`, `/admin/users`, wrapped in `AdminShell` (desktop sidebar / mobile bottom-nav), guarded by role via `AdminRoleCache` in `lib/providers/admin_provider.dart`.

Your tasks:
1. **Verify the role guard** is airtight — an admin refreshing directly on `/admin/...` (before the profile Future resolves) must still be let in; a non-admin must be bounced to `/home`. Fix edge cases in `lib/router.dart`/`admin_provider.dart`.
2. **Make each admin page responsive** on large screens and on a phone browser.
3. Sanity-check the admin flows work end-to-end: menu add/edit/delete, order paid-toggle, user list with debt.

---

## SECTION 3 — CONTINUE CLEANUP (safety net)

Re-sweep the repo for anything dead or unreferenced and remove it:
- Search `lib/`, `pubspec.yaml`, and root for **unused imports, unused dependencies, leftover seed/dump JSON, orphan scripts**. Nothing outside `lib/`/`android/`/`ios/`/`web/`/`windows/`/`linux/`/`macos/`/`test/` should be needed at runtime.
- **Dependencies to review** in `pubspec.yaml`: `intl` may now be unused — verify every dependency is actually imported somewhere; remove what isn't. Run `flutter pub get` after any change.
- Remove the now-empty `scratch/` directory if still present.
- Keep `database.rules.json`, `firebase.json`, `pubspec.yaml`, `lib/**`, `test/**`, `web/**`.

---

## SECTION 4 — OPTIMIZATION & POLISH (recommendations — implement the sensible ones)

1. **Loading/empty/error states**: skeleton/shimmer on home menus + history; pull-to-refresh; and a **retry button** on every failed data load instead of a blank screen.
2. **De-duplicate helpers**: `_rupiah()` and date formatters are copied across admin pages — extract one shared utility (e.g. `lib/utils/formatters.dart`).
3. **Move hardcoded strings** to `AppConstants`.
4. **Query efficiency**: the admin panel currently loads all orders + all users + menu on each visit. Keep it simple for a prototype, but at minimum add loading feedback; note (in a README/comment) where pagination/streams would go later.
5. **Performance**: ensure images are optimized (webP or sized), avoid unnecessary rebuilds with Riverpod selectors where easy, and make sure `flutter build web` bundles cleanly.
6. **Cross-platform consistency**: the exact same code must compile & run on **web + Android + iOS** (and ideally Windows). No `dart:io` lingering in web-reachable code except behind `kIsWeb` guards (check `image_upload_service.dart` and `profile_page.dart`).

---

## SECTION 5 — TEST & VERIFY EVERYTHING

Treat this as a production product. Work through the whole flow as a **real user** on the web:
1. Cold open (logged out) → `/auth`.
2. Login / Register (create a throwaway test account — this is a prototype DB, you are authorized).
3. Land on **Home** → see menus; open **Order** → select days + items → **Checkout** → choose payment → confirm.
4. View **History** (past orders, Lunas/Hutang badges).
5. View **Profile** (photo, info, change password).
6. If your account has `role: "admin"`, open the **Panel Admin** and exercise menu/orders/users pages.
7. Repeat the same on a **phone-width** browser window (narrow) to confirm the mobile shell still works.

### Required: unit/widget tests
- Add/keep tests for: `AppUser` role serialization (already in `test/user_role_test.dart` — extend if needed), phone normalization, and a smoke test. Add at least one **router guard** test for admin access if feasible.

---

## SECTION 6 — EXECUTION RULES

1. Work **only** inside `C:\Users\jundi\StudioProjects\dc_multiplatforms`.
2. Do **not** touch Firebase Console / deploy rules (that is a manual step for the owner). Only keep `database.rules.json` in sync with any DB-structure change.
3. Make small, **reversible** changes. Commit logically (`git add`/`git commit`) when a unit of work is verified — the user tracks progress in `STATUS.md`.
4. Match existing code style: comment density, naming, idiom (Indonesian UI strings, English code comments).
5. Preserve existing functionality — don't break the mobile app.

---

## SECTION 7 — SAFEGUARDS (non-negotiable)

- **Never leave the build broken or tests failing.** After ANY change run:
  - `flutter analyze` → **0 errors, 0 warnings**
  - `flutter test` → **all pass**
  - `flutter build web --release` → success
  - `flutter build apk --debug` → success (do not ship a mobile regression)
- If a change would require deleting something you're unsure about, **leave it** and note it instead of guessing.

---

## SECTION 8 — OUTPUT & DONE CRITERIA

You are done when ALL of the following hold:
- [ ] Web user flow works end-to-end in a browser (desktop AND phone-width).
- [ ] Admin panel works and the role guard is airtight.
- [ ] `scratch/` and any leftover seed/dump JSON are gone; `pubspec.yaml` is clean of unused deps.
- [ ] `flutter analyze` = 0 issues, `flutter test` all green, `flutter build web` ✓, `flutter build apk --debug` ✓.
- [ ] `STATUS.md` updated with every change, file list, validation result, and explicit next steps.

Report each major change as: **What / Files / Why / Validation** — concise, no fluff.
