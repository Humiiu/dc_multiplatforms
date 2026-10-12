# Architecture – Dian Catering App (Customer Mobile)

## 1. Tujuan aplikasi
Menyediakan platform pemesanan makanan catering untuk siswa (customer) dengan fitur login, pemilihan menu mingguan, order, checkout, riwayat pembayaran, dan profil pengguna.

## 2. Dua sisi aplikasi (hanya sisi **customer** yang ada saat ini)
| Role    | Platform            | Entry point |
|---------|---------------------|-------------|
| Customer| Flutter mobile app | `/auth` → `/home` → `/order` → `/checkout` → `/history` → `/profile` |
| Admin   | **Website (akan datang)** – belum ada UI atau PNG, sehingga tidak dicantumkan di roadmap saat ini. |

## 3. Alur order (customer)
1. **Login / Register** – `AuthPage` (tab‑based UI, mock). 
2. **Home** – greeting, kartu “Debt”, carousel menu mingguan, CTA “Atur Preferensi”. 
3. **Order** – pilih hari, tampilkan ringkasan, pilih metode pembayaran (Pay Now / Pay Later). 
4. **Checkout** – total tagihan, pilih metode pembayaran (QR‑IS atau Pay Later), konfirmasi. 
5. **History** – daftar semua order, filter (Semua / Lunas / Belum Lunas), tombol “Bayar Sekarang” bila belum lunas. 
6. **Profile** – data statik profil, aksi edit, ubah password, hubungi admin via WhatsApp.

## 4. Aturan “ngutang” (Pay Later) – backend belum ada
- Order dengan **Pay Later** memerlukan **konfirmasi WhatsApp ke admin** sebelum diterima. 
- **Jatuh tempo**: Sabtu atau Minggu minggu itu (belum diputuskan secara pasti). 
- Nomor admin **placeholder** `ADMIN_WA_NUMBER` – akan diganti setelah admin website siap.

## 5. Stack teknologi (saat ini)
- **Flutter** (Dart) – UI. 
- **Riverpod** (`flutter_riverpod`) – state management (demo). 
- **go_router** – routing. 
- **google_fonts**, **url_launcher** – UI dependencies. 
- **Firebase** – direncanakan untuk fase backend (belum di‑setup).

## 6. Struktur folder `lib/` (saat ini)
```
lib/
│─ core/            → constants, greetings, theme
│─ models/          → data class (CartItem, Menu, Order, User) – mock only
│─ providers/       → Riverpod providers (auth, order, checkout, admin, user) – demo
│─ services/        → admin‑WhatsApp, auth, database, image‑upload (mock)
│─ ui/              → halaman UI (auth_page, home_page, order_page, checkout_page, history_page, profile_page, main_shell)
│─ widgets/         → reusable UI (error_widget, logo_widget)
│─ utils/          → formatters
│─ firebase_options.dart (generated, belum dipakai)
```

## 7. Keputusan teknis yang dapat dipastikan dari kode & log
| Keputusan | Detail |
|----------|--------|
| **State management** | Riverpod (demo). |
| **Routing** | go_router dengan ShellRoute untuk bottom navigation. |
| **Design token** | `AppColors`, `AppRadius`, `AppShadows`, `AppTextStyles` (di `core/theme.dart`). |
| **Typography** | `google_fonts` dengan Playfair Display & Plus Jakarta Sans. |
| **Bottom navigation** | Tinggi 64 dp, label + ikon, state aktif `AppColors.primary` (maroon). |
| **Auth UI** | Tab “Login / Register”, input field standar, toggle password belum ada (TODO). |
| **Weekly menu carousel** | `PageView` otomatis tiap 4 detik, card 240 dp (log). |
| **Debt card** | CTA “Atur Preferensi” → navigasi ke `/order`. |
| **Payment method UI** | Card pilihan QR‑IS atau Pay Later dengan border‑selected (`AppColors.borderSelected`). |
| **History filter** | 3 tab (Semua / Lunas / Belum Lunas). |
| **Profile actions** | Edit Profile, Ubah Password, Hubungi Admin (WhatsApp). |
| **Admin WhatsApp Service** | Placeholder `ADMIN_WA_NUMBER`. |
| **Mock data** | Semua data (greeting, menu, order, history) di‑hard‑code / `demo_state.dart`. |

## 8. Hal yang **belum ditentukan** (ditandai “belum ditentukan”)
- Nama & struktur koleksi Firestore (menu, order, user, bills). 
- Mekanisme otentikasi Firebase (email vs username mapping). 
- Detil alur “ngutang” (jam konfirmasi, template pesan WA). 
- Pilihan payment gateway (QR‑IS provider, integrasi). 
- Rencana backend state management (repo pattern, provider). 
