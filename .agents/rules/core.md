# Core Rules — Dian Catering App (berlaku untuk SEMUA task)

Rules ini universal: desain, frontend, backend, bugfix, refactor, apa pun.
`01-design-fidelity.md` dan `02-backend-firebase.md` melengkapi rules ini, bukan menggantikan.

## 1. Tentang proyek
- Aplikasi Dian Catering: dua sisi, yaitu app customer (pesan menu, bayar via payment
  gateway atau "ngutang") dan dashboard admin (kelola menu, omzet mingguan, jumlah siswa
  yang beli, tagihan, absen ketring).
- Stack: Flutter (path: `C:\Users\jundi\StudioProjects\dc_multiplatforms`).
  Backend direncanakan memakai Firebase.
- Tema: minimalist elegan. Bahasa UI: Indonesia. Font lewat `google_fonts`
  (Playfair Display, Plus Jakarta Sans).
- Kondisi saat ini: frontend customer (login, register, home, order, checkout, history,
  profile, bottom navigation) sudah berbentuk mock UI. Backend BELUM dimulai. Dashboard
  admin BELUM punya UI maupun desain.

## 2. Dokumen proyek (folder `docs/`)
- `*.png`: desain tiap halaman (sumber kebenaran tampilan).
- `ARCHITECTURE.md`: gambaran besar, alur bisnis, keputusan teknis.
- `FRONTEND_PROGRESS.md`: log frontend/desain. Update setiap task frontend.
- `design-specs/<screen>.md`: spec hasil membaca PNG per halaman.
- `DATA_MODEL.md` dan `BACKEND_PROGRESS.md`: dibuat BARU saat backend dimulai.
  Jangan dibuat sebelum user menyatakan backend mulai.
- Di awal setiap task, baca dokumen yang relevan. Kalau dokumen yang dibutuhkan
  belum ada, katakan, jangan mengarang isinya.

## 3. Fase kerja dan batasan
- FASE DESAIN: hanya ubah tampilan (layout, warna, tipografi, card, spacing).
  Jangan ubah logic, navigasi, dependency, atau sentuh backend.
- FASE BACKEND: hanya tambah integrasi di area yang bertanda `TODO(backend)`.
  Jangan ubah layout, tema, design token, atau widget reusable tanpa persetujuan user.
- Komentar `TODO(backend)` dipertahankan sampai integrasinya selesai dan teruji.
  Setelah itu hapus komentarnya dan catat di progress log.
- Data mock (`demo_state.dart`, `constants.dart`, daftar menu statis) tetap dipakai
  sampai benar-benar digantikan oleh backend.
- Dashboard admin: jangan dibuat UI-nya sebelum ada desain PNG-nya.

## 4. Plan Mode vs Act Mode
- PLAN MODE: baca kode dan docs, analisis, susun rencana. Tidak mengubah file dan tidak
  bisa membaca gambar. Rencana menyebut file apa yang akan diubah dan alasannya.
- ACT MODE: eksekusi rencana. Saat user pindah dari Plan ke Act, langsung kerjakan
  rencana itu tanpa menunggu konfirmasi lagi. Boleh membaca gambar dari folder desain.
- Larangan yang hanya berlaku di Plan Mode (misal "jangan ubah file") TIDAK berlaku
  setelah user pindah ke Act Mode.
- Kalau di Act Mode kode tidak cocok dengan rencana atau ada hal tak terduga, berhenti
  dan lapor. Jangan improvisasi besar-besaran.

## 5. Ruang lingkup (scope)
- Kerjakan HANYA yang diminta. Satu task bisa berupa satu halaman, atau daftar/semua
  halaman yang disebut user, yang dikerjakan berurutan satu per satu tanpa berhenti
  di antaranya.
- Kalau user meminta beberapa/semua halaman, selesaikan semuanya dalam satu task.
  Berhenti lebih awal hanya jika ada hambatan nyata (build gagal dan tidak bisa
  diperbaiki, file desain tidak ada, detail penting benar-benar tidak jelas).
- Dilarang refactor, rename, hapus file, atau menambah/upgrade package tanpa izin
  eksplisit. Kalau butuh package baru, jelaskan alasannya dan tunggu persetujuan.
- Temuan di luar scope (bug, ide perbaikan) dicatat di akhir laporan, tidak langsung
  dikerjakan.
- Jangan menambah fitur yang tidak diminta.

## 6. Jangan menebak, tapi jangan terlalu banyak bertanya
- Kalau acuannya sudah ada (PNG, design spec, docs, kode), langsung kerjakan. Jangan
  minta user menyebutkan detail perubahan yang sudah bisa diambil dari acuan itu.
- Tanya user hanya untuk info yang benar-benar tidak ada di acuan manapun (nama field,
  keputusan bisnis, detail tampilan yang tidak jelas). Maksimal 3 pertanyaan sekaligus,
  ringkas, sertakan opsi dan rekomendasimu.
- Jangan mengarang nama package, class, API, atau fungsi library. Cek dulu di kode,
  `pubspec.yaml`, atau dokumentasi resmi. Kalau tidak yakin, katakan tidak yakin.
- Keputusan bisnis (aturan ngutang, alur bayar, hak akses) mengikuti `ARCHITECTURE.md`.
  Jangan mengubahnya sendiri.
- Jika klaim di progress log tidak cocok dengan kode, percaya kode, lalu laporkan
  ketidakcocokannya.

## 7. Kualitas kode (Flutter)
- Ikuti struktur folder dan pola yang sudah ada (`lib/core`, `lib/ui`, `lib/widgets`,
  `lib/services`). Konsisten dengan penamaan yang ada.
- Pakai design token dari `lib/core/theme.dart` (`AppColors`, `AppRadius`, `AppShadows`,
  `AppTextStyles`). Dilarang hardcode warna, ukuran teks, radius, atau shadow di halaman.
- Widget yang dipakai berulang masuk ke `lib/ui/shared_widgets.dart` atau `lib/widgets/`.
  Jangan copy-paste blok UI.
- Pecah `build()` yang panjang menjadi widget kecil. Pakai `const` bila memungkinkan.
- Layout harus aman di lebar layar kecil sampai besar (tidak overflow). Pakai
  `LayoutBuilder`/`MediaQuery`/`Flexible`/`Expanded` seperlunya.
- Lepas resource: `dispose()` untuk controller, timer, dan listener.
- Tangani state loading, kosong, dan gagal. Pesan ke user ramah dan berbahasa Indonesia,
  bukan stack trace.
- Jangan tinggalkan kode mati, `print` debug, atau `TODO` tanpa konteks.
- Komentar hanya untuk "kenapa", bukan "apa".

## 8. Keamanan dan rahasia
- JANGAN menulis API key, secret, token, atau password di kode atau di chat. Pakai
  file config yang di-ignore git.
- Pastikan `.gitignore` menutup file rahasia. Jangan commit file rahasia.
- Data pribadi customer (nama, nomor telepon, riwayat tagihan) sensitif. Jangan di-log
  dan jangan ditampilkan ke user yang tidak berhak.
- Jangan menjalankan perintah destruktif (hapus massal, reset database, force push,
  `rm -rf`) tanpa konfirmasi eksplisit user.

## 9. Verifikasi sebelum bilang "selesai"
- `flutter analyze` bersih (tidak ada error/warning baru).
- `flutter test` lulus kalau ada test.
- `git diff --check` bersih.
- Baca ulang kode yang diubah dari awal sampai akhir.
- Bedakan dengan jujur: "sudah dijalankan" vs "seharusnya jalan menurut kode".
  Dilarang bilang "sudah berfungsi" kalau belum dicoba.
- Verifikasi visual: sebutkan di mana dicek (Chrome, emulator, device) dan ukuran layarnya.
  Kalau tidak bisa merender, katakan, lalu minta user mengirim screenshot hasilnya.

## 10. Progress log dan handoff
- Task frontend/desain -> update `docs/FRONTEND_PROGRESS.md`.
- Task backend -> update `docs/BACKEND_PROGRESS.md` (setelah dibuat).
- Pertahankan struktur log yang sudah ada: status per halaman, file diubah, token dan widget
  reusable, package ditambahkan, data mock, daftar TODO(backend), keputusan dan alasannya,
  hal yang belum dikerjakan.
- Update log SETIAP SELESAI satu halaman/fitur (bukan di akhir saja), supaya kalau task
  terputus, sesi berikutnya tahu persis sampai mana.
- Tiap entri: tanggal, task, file yang diubah, yang selesai, yang masih beda/belum,
  keputusan penting, langkah berikutnya.
- Keputusan arsitektur baru dicatat di `docs/ARCHITECTURE.md`.

## 11. Git & Backup Antar Perangkat
- Setiap selesai satu task / progres fitur / revisi UI dan terverifikasi bersih (analyze + test lulus):
  - Lakukan git commit secara berkala (checkpoint aman) dengan pesan deskriptif.
  - Ini memastikan jika terjadi bug fatal, kode dapat di-reverse/revert kapan pun dengan aman (`git revert` / `git checkout`).
  - Berikan pengingat atau jalankan push (`git push origin master`) agar tersimpan di cloud GitHub sebagai backup untuk sinkronisasi di semua perangkat ngoding.

## 12. Komunikasi
- **Wajib Pengingat Emulator**: Di setiap akhir task revisi/bugfix/UI polish, WAJIB sertakan petunjuk command pengujian emulator:
  1. Launch emulator: flutter emulators --launch Medium_Phone
  2. Jalankan app: flutter run
  3. Shortcut: tekan `r` untuk Hot Reload di terminal.
- Bahasa Indonesia, singkat, langsung ke inti. Jelaskan istilah teknis seperlunya.
- Akhir task: ringkas apa yang diubah, apa yang perlu dicek user secara manual,
  dan temuan di luar scope.
- Jujur soal kekurangan dan ketidakpastian. Lebih baik bilang "belum yakin" daripada
  mengarang.
## 13. Siklus Kerja Disiplin & Instruction Set (WAJIB DIPATUHI SETIAP MODEL)
- **Ritual Pra-Eksekusi ("Baca Bismillah / Mantapkan Instruksi Dulu")**: Sebelum mulai mengetik kode atau tool apapun, WAJIB baca ulang semua instruksi user, PROJECT_SPEC.md, ARCHITECTURE.md, dan log progres. Mantapkan pemahaman terlebih dahulu.
- **Planning & "Grill-Me" Protocol**: Saat membuat perencanaan fitur/solusi baru, WAJIB lakukan wawancara interaktif (Grill-Me) dengan user: ajukan pertanyaan kritis mengenai kebutuhan proyek, berikan opsi dan rekomendasi terbaik, lalu tuliskan action plan secara terstruktur.
- **Zero Assumptions & Scope Guardrail**: Dilarang keras berasumsi sendiri. Jika bingung atau ambigu, tanyakan langsung ke user. Dilarang melakukan hal-hal di luar instruksi user. Jika punya ide bagus/inovatif, tanyakan dan usulkan dahulu, jangan langsung eksekusi tanpa izin.
- **Eksekusi Bertahap**: Kerjakan satu per satu secara terfokus, jangan borongan.
- **Double Check Verifikasi**: Selalu periksa kembali kode, jalankan flutter analyze, dan pastikan 0 error sebelum menyatakan tugas selesai.
- **Diagnosa Bug**: Jelaskan akar masalah (root cause) dahulu -> paparkan solusi -> tanyakan apakah user ingin model yang mengeksekusi atau user ingin mencoba sendiri.
- **Proteksi PIN Owner**: Data keuangan, omzet, modal, dan laba pada Web Admin wajib dilindungi PIN Owner dengan auto-lock; karyawan tidak boleh melihat data ini.
