---
name: design-polish
description: Merapikan dan menyamakan UI halaman aplikasi Dian Catering dengan desain PNG (spacing, warna, tipografi, card). Bisa satu halaman atau semua halaman berurutan. Gunakan saat user meminta polish, rapikan, atau samakan tampilan dengan desain.
---

# design-polish

Ikuti `01-design-fidelity.md` dan `00-core.md`. PNG di `docs/` adalah instruksinya:
user tidak perlu menyebut detail perubahan. Jangan minta instruksi spesifik.

## Menentukan daftar halaman
- Kalau user menyebut satu halaman, kerjakan itu saja.
- Kalau user minta beberapa atau semua halaman, ikuti "Roadmap Polish" di
  `docs/FRONTEND_PROGRESS.md`. Kalau belum ada, pakai urutan: login, register, home,
  order, checkout, history, profile, bottom navigation.
- Dashboard admin tidak termasuk (belum ada desain).

## Untuk TIAP halaman, ulangi langkah 1 sampai 6

### Langkah 1 — Persiapan
1. Cari file kode halaman itu dan semua komponen yang dipakainya.
2. Cek apakah `docs/design-specs/<halaman>.md` sudah ada.
3. Ringkas kondisi kode: struktur, komponen, nilai yang di-hardcode.
4. Tentukan PNG mana yang harus dibaca.

### Langkah 2 — Baca desain (butuh Act Mode untuk membaca gambar)
1. Buka dan baca PNG halaman itu dari `docs/` (sebut nama file yang dipakai).
2. Tulis `docs/design-specs/<halaman>.md` sesuai poin 3 di `01-design-fidelity.md`.
3. Tanya user hanya untuk detail yang benar-benar tidak jelas di PNG (maksimal 3
   pertanyaan). Kalau tidak ada, langsung lanjut.

### Langkah 3 — Samakan token
1. Cocokkan warna, ukuran, spacing di spec dengan token di `lib/core/theme.dart`.
2. Kalau ada nilai baru yang belum ada, tambahkan ke token. Jangan hardcode.

### Langkah 4 — Implementasi
1. Bandingkan spec dengan kode, lalu perbaiki SEMUA selisih langsung di kode, dari
   section paling atas ke bawah.
2. Pisahkan komponen reusable (card, tombol, input) kalau belum ada.
3. Jangan sentuh logic, navigasi, dependency, atau komentar `TODO(backend)`.
4. Kalau mengubah widget bersama, cek halaman lain yang memakainya.

### Langkah 5 — Verifikasi
1. Jalankan `flutter analyze`, perbaiki masalah yang muncul.
2. Jalankan checklist verifikasi (poin 6 di `01-design-fidelity.md`), satu per satu.
3. Buka PNG sekali lagi dan bandingkan dengan hasil akhir.
4. Tulis daftar perbedaan yang masih ada, jujur apa adanya.

### Langkah 6 — Catat dan lanjut
1. Update status halaman itu di `docs/FRONTEND_PROGRESS.md` (file diubah, token baru,
   selisih yang tersisa).
2. Kalau user meminta beberapa/semua halaman: LANGSUNG lanjut ke halaman berikutnya
   tanpa menunggu review.
3. Kalau user hanya meminta satu halaman: berhenti dan laporkan.

## Kapan berhenti lebih awal
Hanya jika: `flutter analyze` gagal dan tidak bisa diperbaiki, PNG tidak ada atau tidak
bisa dibaca, atau ada detail penting yang benar-benar tidak jelas. Lapor halaman mana
yang sudah selesai dan yang belum.

## Laporan akhir
Ringkasan per halaman: apa yang diubah, selisih yang masih ada, apa yang perlu dicek
manual oleh user (terutama verifikasi visual di emulator/device), dan temuan di luar scope.