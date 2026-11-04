# Backend Progress Log — Dian Catering

Dokumen ini mencatat seluruh perkembangan implementasi backend aplikasi Dian Catering.

---

## 1. Status per Fitur

- **Setup & Arsitektur Database**: Selesai dirancang menggunakan **Firebase Realtime Database (RTDB)** dan **Firebase Authentication** dengan email masking virtual (`username@diancatering.app`). Dokumen acuan `docs/DATA_MODEL.md` telah dibuat dan `database.rules.json` telah dilengkapi (termasuk node `debts` dan `user_orders`).
- **Fitur 1: Autentikasi & Registrasi Akun**: Selesai. Form Login & Register di `lib/ui/auth_page.dart` sudah terhubung ke `AuthService` dan `DatabaseService` dengan validasi lengkap, email masking virtual, loading state, dan unit testing.
- **Fitur 2: Profil Siswa**: Selesai. Data nama, kelas, jurusan, dan nomor telepon ditampilkan dinamis di `ProfilePage` dan sapaan `HomePage` melalui `currentUserProfileProvider`. Dialog edit profil nama, ubah password akun, integrasi WhatsApp admin dinamis, serta tombol Logout telah aktif.
- **Fitur 3: Menu Mingguan Dinamis**: Selesai. Data menu harian dimuat dinamis dari Firebase RTDB node `/menus` via `weeklyMenuProvider`, dengan fallback otomatis ke menu mingguan default jika data belum diisi atau offline. Carousel `HomePage` dan kartu pemilihan hari di `OrderPage` sudah tersambung penuh.
- **Fitur 4: Pemesanan & Alur Order**: Selesai. Logika `OrderValidator` dibuat (harga flat Rp 20.000/box, cut-off malam 21:30 WIB), model `Order` diperbarui, `OrderProvider` terhubung ke RTDB via `createOrder()`, tombol 'Pay Now' di `CheckoutPage` memanggil `submitCurrentOrder()` dengan handling loading state, proteksi plafon Pay Later, aksi konfirmasi WhatsApp admin langsung dari snackbar, dan unit testing di `test/order_validator_test.dart` & `test/order_model_test.dart` lulus 100%.
- **Fitur 5: Tagihan & Pay Later (Ngutang)**: Selesai. Proteksi plafon hutang maksimal Rp 100.000 diterapkan di `OrderValidator.canUsePayLater()`, stream saldo hutang real-time di `userDebtStreamProvider`, tampilan kartu `_DebtCard` di `HomePage` tersambung dinamis, dan pelunasan hutang terhubung ke RTDB via `payDebt()`.
- **Fitur 6: Riwayat (History)**: Selesai. `HistoryPage` terhubung dinamis ke `userOrdersStreamProvider` untuk memuat riwayat order real dari Firebase RTDB `/orders`, dilengkapi filter 'All', 'Paid', 'Unpaid', integrasi konfirmasi WhatsApp Admin dinamis berdasarkan nama/kelas siswa untuk pesanan belum lunas, pull-to-refresh (`RefreshIndicator`), serta graceful fallback ke data demo saat mode tamu offline.

---

## 2. Daftar File Dibuat / Diubah
- `docs/DATA_MODEL.md`: Dokumen sumber kebenaran struktur tree RTDB dan autentikasi.
- `docs/BACKEND_PROGRESS.md`: Log progres implementasi backend.
- `database.rules.json`: Aturan keamanan RTDB untuk `users`, `usernames`, `phones`, `menus`, `orders`, `user_orders`, dan `debts`.
- `lib/models/user.dart`: Model `AppUser`, enum `Kelas`, enum `Jurusan`, enum `UserRole`.
- `lib/models/order.dart`: Model `Order`, getter `weekLabel`, `isOverdue`, helper mapping legacy fields & serialization.
- `lib/services/auth_service.dart`: Integrasi Firebase Auth dengan email masking virtual, registrasi siswa lengkap, dan sign in.
- `lib/services/database_service.dart`: CRUD user, menu, order, debt, dan lookup index usernames & phones pada RTDB.
- `lib/services/admin_whatsapp_service.dart`: Integrasi link WhatsApp admin dinamis dengan error handling `canLaunchUrl`.
- `lib/providers/user_provider.dart`: Provider `currentUserProfileProvider` dan `userDataProvider`.
- `lib/providers/menu_provider.dart`: Provider `weeklyMenuProvider`, `homeMenuItemsProvider`, `orderDaysProvider`.
- `lib/providers/order_provider.dart`: Provider `userDebtStreamProvider`, `userOrdersStreamProvider`, dan service `OrderService.submitCurrentOrder()`.
- `lib/ui/shared_widgets.dart`: Dukungan `isLoading` pada `DemoPrimaryButton`.
- `lib/ui/auth_page.dart`: Form Login & Register terhubung langsung ke Firebase Auth & RTDB.
- `lib/ui/home_page.dart`: Sapaan dinamis, saldo debt real-time, menu carousel mingguan dinamis, dan refresh indicator.
- `lib/ui/order_page.dart`: Hari pesanan dinamis dari menu mingguan RTDB.
- `lib/ui/checkout_page.dart`: Alur submit pesanan & pelunasan tagihan terhubung ke `orderServiceProvider.submitCurrentOrder()`.
- `lib/ui/history_page.dart`: Riwayat pesanan dinamis dari `userOrdersStreamProvider` dengan konfirmasi WA admin & refresh indicator.
- `lib/ui/demo_state.dart`: State form pemilihan pesanan lokal & fallback offline demo.
- `test/auth_masking_test.dart`: Unit testing sanitasi dan masking email virtual username.
- `test/menu_model_test.dart`: Unit testing serialization model menu mingguan.
- `test/order_validator_test.dart`: Unit testing aturan bisnis katering (harga flat, plafon hutang, cut-off 21:30 WIB).
- `test/order_model_test.dart`: Unit testing serialization & logic model Order.

---

## 3. Package Backend yang Digunakan
- `firebase_core: ^5.0.0`: Inisialisasi Firebase multiplatform.
- `firebase_auth: ^7.0.0`: Otentikasi pengguna, manajemen session, dan token.
- `firebase_database: ^13.0.0`: Database real-time no-SQL (RTDB) untuk menyimpan data user, menu, order, dan debt.
- `firebase_storage: ^14.0.0`: Penyimpanan foto profil user dan foto menu.
- `cloud_functions: ^7.0.0`: Logika server-side bila dibutuhkan (opsional).

---

## 4. Status Area TODO(backend)
- Seluruh area `TODO(backend)` pada file kode `lib/` telah tuntas diintegrasikan (0 TODO tersisa di `lib/`).

---

## Log Riwayat Pengerjaan

### 01. Inisialisasi Arsitektur Backend & Pembuatan Data Model (02 Nov 2026)
Task: Memulai fase backend aplikasi Dian Catering. Menyusun dokumen acuan `docs/DATA_MODEL.md` berbasis Firebase Realtime Database dan Firebase Auth email masking sesuai persetujuan pengguna.

### 02. Implementasi Fitur 1: Autentikasi & Registrasi Akun (02 Nov 2026)
Task: Mengimplementasikan `AuthService` dengan masking email virtual (`username@diancatering.app`), menghubungkan form Login dan Register di `AuthPage` ke Firebase Auth dan Realtime Database, menambahkan handling loading indicator di tombol utama, serta menambahkan unit test sanitasi masking.
Verifikasi: `flutter analyze` bersih (0 issues), `flutter test` lulus (38 tests passed).

### 03. Implementasi Fitur 2: Profil Siswa & Sapaan Dinamis (02 Nov 2026)
Task: Menghubungkan profil pengguna pada `ProfilePage` dan sapaan `HomePage` ke Firebase RTDB via `currentUserProfileProvider`. Mengaktifkan dialog edit nama profil, ubah password Firebase Auth, integrasi WhatsApp admin dinamis berdasarkan nama/kelas siswa aktif, serta logout session.
Verifikasi: `flutter analyze` bersih (0 issues), `flutter test` lulus (38 tests passed).

### 04. Implementasi Fitur 3: Menu Mingguan Dinamis (02 Nov 2026)
Task: Mengimplementasikan data model `CateringDayMenu`, provider `weeklyMenuProvider`, `homeMenuItemsProvider`, dan `orderDaysProvider`. Menyambungkan carousel menu pada `HomePage` dan pemilihan hari pesanan pada `OrderPage` ke data RTDB node `/menus` dengan graceful fallback ke menu default jika database belum terisi atau offline, serta menambahkan unit test serialization menu.
Verifikasi: `flutter analyze` bersih (0 issues), `flutter test` lulus (42 tests passed).

### 05. Implementasi Fitur 4 & 5: Pemesanan, Validasi Tagihan & Pelunasan (02 Nov 2026)
Task: Membuat `OrderValidator` untuk proteksi batas plafon Pay Later Rp 100.000, flat price Rp 20.000/box, dan cut-off 21:30 WIB. Menyambungkan `CheckoutPage` ke `OrderService.submitCurrentOrder()`, menyalurkan pembuatan order baru maupun pelunasan hutang langsung ke node RTDB `/orders` dan `/debts`.
Verifikasi: `flutter analyze` bersih (0 issues), `flutter test` lulus (45 tests passed).

### 06. Implementasi Fitur 6: Riwayat Pesanan Realtime & Security Rules Hardening (02 Nov 2026)
Task: Menyambungkan `HistoryPage` ke `userOrdersStreamProvider` untuk menampilkan pesanan siswa secara real-time dari Firebase RTDB, mengaktifkan filter status pembayaran ('All', 'Paid', 'Unpaid'), menghubungkan konfirmasi WA admin dinamis untuk pesanan hutang, menambahkan `RefreshIndicator`, memperbarui `database.rules.json` untuk node `debts` dan `user_orders`, serta menambahkan unit test model Order di `test/order_model_test.dart`.
Verifikasi: `flutter analyze` bersih (0 issues), `flutter test` lulus (50 tests passed).

### 07. Pengaktifan Firebase Realtime Database Penuh & Fitur Profil Lengkap (05 Nov 2026)
Task: Memulihkan konfigurasi piKey Firebase pada irebase_options.dart & inisialisasi di semua platform, menghapus bypass demo login form kosong pada AuthPage, menambahkan fungsi changePassword (dengan reautentikasi password lama & validasi 3-field), changeUsername dengan lookup unik di RTDB, updateStudentProfile (unlocked: nama, kelas, jurusan, telepon), serta manajemen PFP di ImageUploadService dan RTDB (kamera langsung, galeri, hapus foto profil).
Verifikasi: lutter analyze 0 issues, lutter test lulus (54 tests passed).
