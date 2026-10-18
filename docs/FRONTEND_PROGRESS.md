# Frontend Progress Log

## 1. Status per halaman

- Login: Selesai untuk mock UI. Masih perlu backend auth real dan validasi form yang sebenarnya.
- Register: Selesai untuk mock UI. Form sudah mencakup nama lengkap, username, kelas, jurusan, nomor telepon, dan password. Belum terhubung ke Firebase/Auth.
- Home: Kartu tagihan, carousel menu 240 dp yang bisa di-swipe dan berganti otomatis, request khusus, dan CTA. Greeting dipilih acak dari `lib/core/greetings.dart` saat halaman dibuka.
- Order: Urutan mengikuti Figma: Select Days → Order Summary → Payment Method. Semua kartu hari tetap dapat dipilih, dengan state selected, ringkasan, dan pilihan pembayaran.
- Checkout: Header TOTAL BILL, kartu QRIS/Virtual Account/E-Wallet dengan state selected, total, dan CTA footer mengikuti design context Figma.
- History: Header, ikon receipt, judul/total terpusat, filter Semua/Sudah Lunas/Belum Lunas, badge status ikon berwarna, baris detail peach, dan CTA Bayar Sekarang diselaraskan ke screenshot referensi.
- Profile: Avatar placeholder dibingkai sesuai radius desain; tile menu, warna ikon, subtitle, dan posisi logout diselaraskan.
- Bottom Navigation: Tinggi 64 px, diletakkan di tengah dengan lebar maksimum, ikon dan label tetap sejajar serta state aktif maroon.
- Login/Register: Teks tab terpilih putih; dropdown kelas/jurusan menggunakan dekorasi underline transparan yang sama dengan text field. Logo dipusatkan eksplisit.

Catatan desain: Figma MCP berhasil memberikan design context dan screenshot untuk Login, Home, Order, Checkout, dan History; MCP kemudian mencapai batas pemakaian Starter sehingga asset/variable export lanjutan tidak tersedia. Node Profile yang diperiksa hanya berisi bottom navigation, jadi konten Profile masih mengikuti screenshot/spec lokal. Greeting tetap menggunakan data mock dari `greetings.dart`. Perlu verifikasi visual akhir di emulator karena asset foto/vector Figma belum dapat diekspor.

## 2. Daftar file dibuat/diubah per halaman

- Login/Register: `lib/ui/auth_page.dart`, `lib/widgets/logo_widget.dart`, `lib/core/constants.dart` (register tidak diubah dalam pass desain card)
- Home: `lib/ui/home_page.dart`
- Order: `lib/ui/order_page.dart`, `lib/ui/demo_state.dart`
- Checkout: `lib/ui/checkout_page.dart`, `lib/ui/demo_state.dart`
- History: `lib/ui/history_page.dart`, `lib/ui/demo_state.dart`
- Profile: `lib/ui/profile_page.dart`
- Shared/Theme/Layout: `lib/core/theme.dart`, `lib/ui/shared_widgets.dart`, `lib/ui/main_shell.dart`
- Admin contact flow: `lib/services/admin_whatsapp_service.dart`

## 3. Design token & widget reusable yang dibuat

- `AppColors`, `AppRadius`, `AppShadows`, `AppTextStyles` di `lib/core/theme.dart`
- `AppColors.borderSelected` untuk state selected pada card hari dan metode pembayaran; `AppColors.chipBackground` untuk filter history.
- `DemoPrimaryButton`, `DemoSectionTitle`, `DemoTopBar`, `_AuthInput`, `_DropdownInput`, `_AuthTab` di `lib/ui/shared_widgets.dart`
- `AppConstants` dan `kelasOptions`/`jurusanOptions` di `lib/core/constants.dart`
- `AdminWhatsappService` di `lib/services/admin_whatsapp_service.dart`

## 4. Package/dependency yang ditambahkan

- `url_launcher: ^6.3.0` — untuk membuka link WhatsApp admin ke URL external application.
- `google_fonts: ^6.3.3` — agar teks mengikuti desain dengan Playfair Display, Plus Jakarta Sans, dan fallback sans serif. Dinaikkan dari `^6.3.0` karena 6.3.0 gagal dikompilasi pada Flutter 3.47/Dart 3.13 (error `const` map dengan key `FontWeight`); 6.3.2 sudah membuat map tersebut non-const dan 6.3.3 menghapus pemakaian `FontWeight.index` yang deprecated.

## 5. Data dummy/mock yang dipakai

- `lib/core/greetings.dart` — pilihan greeting acak yang digunakan kembali pada home.
- `lib/core/constants.dart` — daftar kelas, jurusan, dan nomor admin placeholder.
- `lib/ui/demo_state.dart` — state lokal untuk pesanan, tagihan, status bayar, dan history.
- `lib/ui/home_page.dart` — daftar menu mingguan statis untuk preview UI.
- `lib/ui/auth_page.dart` — field form demo tanpa submit real.

## 6. Daftar TODO(backend)

- `lib/ui/auth_page.dart`: register butuh `createUser`/`signUp`, simpan nama lengkap, username, kelas, jurusan, nomor telepon, password. Bentuk data yang diharapkan: `{ fullName: String, username: String, kelas: String, jurusan: String, phone: String, password: String }`.
- `lib/ui/home_page.dart`: data menu mingguan, saldo/tagihan, preferensi user, dan informasi akun harus diambil dari backend.
- `lib/ui/order_page.dart`: pilih menu, hari kerja, jumlah, dan checkout action butuh koneksi ke data menu + cart state backend real.
- `lib/ui/checkout_page.dart`: simpan order, hitung total, metode pembayaran, dan status hutang harus dihubungkan ke database/backend.
- `lib/ui/history_page.dart`: riwayat order, status lunas/belum lunas, total seluruh ketring, dan invoice harus datang dari API/database.
- `lib/ui/profile_page.dart`: edit profile, ubah password, dan logout harus terhubung ke auth/user backend.
- `lib/services/admin_whatsapp_service.dart`: message templates siap, tapi nomor admin tetap placeholder dan data user masih dummy hingga backend tersedia.
- `lib/core/constants.dart`: `ADMIN_WA_NUMBER` placeholder dan opsi data default harus digantikan bila backend sudah siap.

## 7. Keputusan yang diambil dan alasannya

- Sapaan home dipilih satu kali secara acak dari `greetings.dart` saat halaman dibuka, sesuai implementasi greetings yang sudah tersedia.
- Dropdown register dibenahi agar tetap minimalis dan konsisten dengan style underline input, tanpa mengubah urutan field atau tampilan utama register yang sudah disepakati.
- Figma dijadikan sumber utama ketika ada perbedaan dengan screenshot. Mengikuti Figma menjaga konsistensi visual dengan brief yang diberikan.
- Semua aksi yang membutuhkan data real dipertahankan dalam bentuk demo UI dan diberi komentar `TODO(backend): ...` agar jelas batas frontend vs backend.

## 8. Hal yang belum dikerjakan / langkah berikutnya

- Memvalidasi secara visual pada emulator/device dan menyempurnakan sisa selisih bila ditemukan.
- Avatar profile masih placeholder ikon karena tidak ada foto profil dummy di asset proyek.
- Foto menu dan asset vector belum dapat diekspor dari Figma karena batas tool MCP; area gambar menu masih menggunakan treatment gradient lokal.
- Validasi setelah pass Figma: `flutter analyze`, `flutter test`, dan `git diff --check` lulus. UI juga diperiksa melalui Chrome pada viewport 440×935; emulator Android tidak tersedia.

## 9. Aturan untuk tool backend

- File UI yang boleh disentuh oleh backend: `lib/ui/*`, `lib/core/*`, `lib/services/admin_whatsapp_service.dart`, `lib/widgets/*`.
- File yang tidak boleh diubah tanpa koordinasi frontend: semua file UI yang sudah dibuat dan semua design token/widget reusable. Backend hanya boleh menambahkan integrasi di area yang sudah dibubuhi `TODO(backend): ...`, bukan mengganti layout/tema.
- Semua perubahan backend harus tetap menjaga frontend-only scope dan tidak mengubah struktur besar aplikasi atau dependency inti tanpa dicatat di log ini.

## 10. Perbaikan build & lingkungan (16 Okt 2026)

Task: memperbaiki agar proyek bisa di-build/dijalankan di laptop ini (di PC user sebelumnya sudah bisa).
Tidak ada perubahan UI, layout, tema, atau logic aplikasi pada task ini.

Penyebab dan perbaikan:

- `android/gradle/wrapper/gradle-wrapper.properties`: Gradle `8.13` → `8.14`. Flutter 3.47 menolak Gradle di bawah 8.14.
- `android/settings.gradle`: Kotlin (`org.jetbrains.kotlin.android`) `1.9.24` → `2.2.20`. Flutter 3.47 memerlukan Kotlin minimal 2.2.20, build gagal dengan pesan "Your project's Kotlin version is lower than Flutter's minimum supported version of 2.2.20".
- `pubspec.yaml` + `pubspec.lock`: `google_fonts` `^6.3.0` → `^6.3.3`. Versi 6.3.0 (yang terkunci di lock file) gagal dikompilasi pada Dart 3.13.

Verifikasi yang sudah dijalankan:

- `flutter pub get` — sukses, `google_fonts` terpasang 6.3.3.
- `flutter build apk --debug` — **berhasil** (`√ Built build\app\outputs\flutter-apk\app-debug.apk`, 412.6s). Ini task `assembleDebug` yang tadinya gagal.
- `flutter build web --debug` — **berhasil** (`√ Built build\web`, 84.0s). Ini target tempat error `google_fonts` pertama kali muncul.
- `flutter analyze` — 0 error; 4 issue lama (1 unused import, 2 `unawaited_return_in_try_block`, 1 deprecation `value`), bukan dari perubahan ini.
- `flutter test` — 34 test, semuanya lulus.
- `flutter run -d web-server --web-port 8091 --debug` — **berhasil**: app ter-build dan tersaji di `http://localhost:8091` (perintah `flutter run` yang tadinya gagal). Proses dihentikan lagi setelah verifikasi.
- `git diff --check` — bersih.

Belum diverifikasi: menjalankan app di perangkat/emulator Android. `flutter devices` di laptop ini hanya mendeteksi Windows desktop, Chrome, dan Edge (tidak ada device/emulator Android), jadi `assembleDebug` yang tadinya gagal sudah dipastikan lolos, tetapi instalasi ke perangkat Android belum dicoba.

Peringatan yang masih ada (belum dikerjakan, hanya warning, tidak memblokir build):

- Flutter memperingatkan Gradle 8.14 dan AGP 8.11.1 dan Kotlin 2.2.20 akan segera di-drop; disarankan Gradle ≥ 9.1.0, AGP ≥ 9.0.1, Kotlin ≥ 2.3.20. Belum dinaikkan karena AGP 9 mengubah DSL (`android.newDsl`) dan berisiko merusak konfigurasi yang ada.
- `android/app/build.gradle` masih `sourceCompatibility`/`targetCompatibility` Java 8 (muncul warning "source value 8 is obsolete").
- Toolchain laptop: Flutter 3.47.7, Dart 3.13.5.
