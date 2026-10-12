---
name: backend-feature
description: Mengerjakan fitur backend Firebase aplikasi Dian Catering: data model, security rules, repository, menyambungkan logic ke UI yang sudah ada lewat area TODO(backend). Gunakan saat user meminta fitur login, order, tagihan, menu, absen, pembayaran, atau penyimpanan data.
---

# backend-feature

Ikuti `00-core.md` dan `02-backend-firebase.md`. Skill ini baru dipakai setelah user
menyatakan backend dimulai.

## Menentukan daftar fitur
- Satu fitur disebut user: kerjakan itu saja.
- Beberapa/semua fitur diminta: kerjakan berurutan satu per satu tanpa berhenti di
  antaranya, mengikuti urutan dari user atau daftar `TODO(backend)` di kode.

## Untuk TIAP fitur, ulangi langkah 1 sampai 5

### Langkah 1 — Pahami
1. Baca `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/BACKEND_PROGRESS.md`.
   Kalau `DATA_MODEL.md` atau `BACKEND_PROGRESS.md` belum ada, buat dulu sesuai
   `02-backend-firebase.md` bagian 1.
2. Cari halaman UI dan kode terkait, termasuk komentar `TODO(backend)`-nya.
3. Ringkas: apa yang sudah ada, apa yang kurang, apa yang akan disentuh.

### Langkah 2 — Rancang
1. Usulkan perubahan data model (collection, field, status) dan security rules.
2. Daftar file yang akan dibuat/diubah dan alasannya.
3. Daftar kasus gagal yang akan ditangani.
4. Tanyakan hanya keputusan yang memang milik user (pemetaan username ke Firebase Auth,
   state management, gateway pembayaran, nomor admin). Maksimal 3 pertanyaan.

### Langkah 3 — Implementasi
1. Update `docs/DATA_MODEL.md` kalau ada perubahan data.
2. Tulis security rules.
3. Buat model dan repository.
4. Sambungkan ke state, lalu ke UI di area `TODO(backend)`. Jangan ubah tampilan.
5. Tangani loading, kosong, error.

### Langkah 4 — Verifikasi
1. `flutter analyze` bersih.
2. Telusuri alur utama dan alur gagal dari awal sampai akhir.
3. Cek ulang security rules: customer tidak bisa membaca/mengubah data orang lain
   atau mengakses fitur admin.
4. Tulis apa yang SUDAH diuji dan apa yang BELUM bisa diuji.

### Langkah 5 — Catat dan lanjut
1. Hapus komentar `TODO(backend)` yang sudah selesai dan teruji.
2. Update `docs/BACKEND_PROGRESS.md` dan docs lain yang berubah.
3. Kalau user meminta beberapa fitur: lanjut ke fitur berikutnya tanpa menunggu review.
4. Kalau hanya satu fitur: berhenti dan laporkan.

## Laporan akhir
Apa yang dibuat, cara user mengetes manual, risiko tersisa, temuan di luar scope.