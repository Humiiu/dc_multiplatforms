# Backend Progress Log — Dian Catering

Dokumen ini mencatat seluruh perkembangan implementasi backend aplikasi Dian Catering.

---

## 1. Status per Fitur

- **Setup & Arsitektur Database**: Selesai dirancang menggunakan **Firebase Realtime Database (RTDB)** dan **Firebase Authentication** dengan email masking virtual (`username@diancatering.app`). Dokumen acuan `docs/DATA_MODEL.md` telah dibuat.
- **Fitur 1: Autentikasi & Registrasi Akun**: Selesai. Form Login & Register di `lib/ui/auth_page.dart` sudah terhubung ke `AuthService` dan `DatabaseService` dengan validasi lengkap, email masking virtual, loading state, dan unit testing.
- **Fitur 2: Profil Siswa**: Selesai. Data nama, kelas, jurusan, dan nomor telepon ditampilkan dinamis di `ProfilePage` dan sapaan `HomePage` melalui `currentUserProfileProvider`. Dialog edit profil nama, ubah password akun, integrasi WhatsApp admin dinamis, serta tombol Logout telah aktif.
- **Fitur 3: Menu Mingguan Dinamis**: Belum dimulai.
- **Fitur 4: Pemesanan & Alur Order**: Belum dimulai.
- **Fitur 5: Tagihan & Pay Later (Ngutang)**: Belum dimulai.
- **Fitur 6: Riwayat (History)**: Belum dimulai.

---

## 2. Daftar File Dibuat / Diubah
- `docs/DATA_MODEL.md`: Dokumen sumber kebenaran struktur tree RTDB dan autentikasi.
- `docs/BACKEND_PROGRESS.md`: Log progres implementasi backend.
- `lib/models/user.dart`: Model `AppUser`, enum `Kelas`, enum `Jurusan`, enum `UserRole`.
- `lib/services/auth_service.dart`: Integrasi Firebase Auth dengan email masking virtual, registrasi siswa lengkap, dan sign in.
- `lib/services/database_service.dart`: CRUD user, lookup index usernames & phones pada RTDB.
- `lib/providers/user_provider.dart`: Provider `currentUserProfileProvider`.
- `lib/ui/shared_widgets.dart`: Dukungan `isLoading` pada `DemoPrimaryButton`.
- `lib/ui/auth_page.dart`: Form Login & Register terhubung langsung ke Firebase Auth & RTDB.
- `test/auth_masking_test.dart`: Unit testing sanitasi dan masking email virtual username.

---

## 3. Package Backend yang Digunakan
- `firebase_core: ^5.0.0`: Inisialisasi Firebase multiplatform.
- `firebase_auth: ^7.0.0`: Otentikasi pengguna, manajemen session, dan token.
- `firebase_database: ^13.0.0`: Database real-time no-SQL (RTDB) untuk menyimpan data user, menu, order, dan debt.
- `firebase_storage: ^14.0.0`: Penyimpanan foto profil user dan foto menu.
- `cloud_functions: ^7.0.0`: Logika server-side bila dibutuhkan (opsional).

---

## 4. Daftar Area TODO(backend) Aktif
1. `lib/ui/home_page.dart:27`: Load greeting dinamis, profil user, saldo debt, dan menu mingguan dari RTDB.
2. `lib/ui/demo_state.dart:143`: Gantukan mock state pemesanan lokal dengan listener pesanan RTDB.
3. `lib/ui/history_page.dart:68`: Hubungkan pelunasan tagihan Pay Now ke status order RTDB.
4. `lib/services/admin_whatsapp_service.dart:54`: Ganti fallback konfirmasi pesanan dengan nomor admin real dan status order di RTDB.

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
