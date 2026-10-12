# Backend & Firebase Rules — Dian Catering App

Berlaku saat task menyentuh data, autentikasi, pembayaran, atau logic server.
Backend BELUM dimulai. Rules ini aktif setelah user menyatakan backend mulai.
Patuhi juga `00-core.md`.

## 1. Memulai fase backend
- Saat user menyatakan backend mulai, BUAT dokumen baru (setelah rencana disetujui):
  `docs/DATA_MODEL.md` dan `docs/BACKEND_PROGRESS.md`.
- Sumber awal: daftar `TODO(backend)` di kode dan `docs/FRONTEND_PROGRESS.md`.
- Pakai area `TODO(backend)` sebagai peta kerja. Backend hanya menambah integrasi di sana,
  bukan mengganti layout atau tema.

## 2. Sumber kebenaran data
- Struktur data (collection, field, tipe, status, relasi) ada di `docs/DATA_MODEL.md`.
- SEBELUM menambah/mengubah field atau collection: update `DATA_MODEL.md` dulu, minta
  user menyetujui, baru implementasi.
- Satu gaya penamaan field di seluruh proyek. Jangan bikin dua nama untuk hal yang sama.

## 3. Pemisahan lapisan
- UI tidak memanggil Firebase langsung. Alurnya: UI -> state -> repository -> Firebase.
- Satu domain satu repository (menu, order, tagihan, absen, user). Letakkan di struktur
  `lib/` yang konsisten dengan pola yang sudah ada.
- Model data (class) terpisah dari UI, dengan konversi ke/dari dokumen Firebase.
- Pendekatan state management (apa yang menggantikan `demo_state.dart`) adalah keputusan
  user. Usulkan opsi dan rekomendasi, jangan menambah package state management sendiri.
- Ganti data mock bertahap per fitur, bukan sekaligus.

## 4. Package dan setup
- Tambah package Firebase (misal `firebase_core`, `firebase_auth`, `cloud_firestore`) hanya
  dengan persetujuan user, dan versi dicek dari `pub.dev`/dokumentasi resmi, bukan tebakan.
- Setup Firebase di Flutter mengikuti dokumentasi resmi FlutterFire.
- Cloud Functions butuh paket billing Blaze. Tanyakan user sebelum memakainya.
- Catat package baru di `BACKEND_PROGRESS.md`.

## 5. Autentikasi dan peran
- Ada dua peran: `customer` dan `admin`. Peran disimpan di tempat yang tidak bisa diubah
  sendiri oleh customer (custom claims atau dokumen yang dilindungi rules).
- Login memakai username, sedangkan Firebase Auth butuh email atau nomor HP. Cara pemetaannya
  adalah KEPUTUSAN USER. Tanyakan, jangan pilih sendiri.
- Field registrasi mengikuti keputusan terbaru user: nama lengkap, username, kelas, jurusan,
  nomor telepon, password. Kalau berubah, update docs dulu.
- JANGAN simpan password di Firestore (walaupun TODO lama menyebut itu). Password diurus
  Firebase Auth.

## 6. Firestore Security Rules (WAJIB)
- Setiap collection baru wajib punya security rules di task yang sama.
- Prinsip: tolak semua secara default, buka hanya yang perlu.
  - Customer hanya boleh membaca/menulis data miliknya sendiri.
  - Admin boleh mengelola menu, tagihan, absen, dan melihat omzet.
  - Menu boleh dibaca user yang login, tapi hanya admin yang boleh menulis.
- Jangan pernah pakai `allow read, write: if true` kecuali user minta eksplisit untuk
  testing, dan beri peringatan jelas.
- Validasi data penting di rules (tipe, rentang, field wajib), bukan hanya di UI.
- Setiap perubahan rules dijelaskan ke user: apa yang dibuka dan apa risikonya.

## 7. Order, tagihan, dan "ngutang"
- Alur bisnis acuan ada di `docs/ARCHITECTURE.md`: pilih hari, pilih metode bayar
  (gateway atau ngutang), jatuh tempo ngutang di Sabtu/Minggu minggu itu.
- Order "ngutang" butuh konfirmasi WhatsApp ke admin sebelum diterima. Status order
  harus eksplisit (misal: menunggu konfirmasi, diterima, ditolak, lunas, jatuh tempo).
  Jangan bikin status liar. Daftarkan semua status di `DATA_MODEL.md`.
- Nomor admin WhatsApp saat ini placeholder (`ADMIN_WA_NUMBER`). Ganti hanya dengan nilai
  dari user.
- Operasi yang mengubah beberapa dokumen sekaligus (buat order + tagihan + update total)
  pakai transaction atau batched write.
- Jangan hitung total harga hanya di client. Harga diambil dari data menu, bukan input user.
- Simpan waktu dengan timestamp server, bukan jam perangkat.

## 8. Payment gateway
- Gateway BELUM dipilih. Tanyakan user sebelum membuat integrasi. Jangan menebak API-nya;
  baca dokumentasi resmi gateway yang dipilih.
- Status pembayaran TIDAK BOLEH dipercaya dari client. Konfirmasi lunas harus datang dari
  server (webhook/callback gateway) dan diverifikasi sebelum status order berubah.
- Secret key gateway tidak boleh ada di aplikasi. Taruh di sisi server.
- Tangani kasus: bayar gagal, kedaluwarsa, bayar dua kali, user menutup app di tengah proses.

## 9. Query dan performa
- Hindari membaca seluruh collection. Pakai filter, limit, dan pagination.
- Data yang jarang berubah (menu minggu ini) boleh di-cache.
- Kalau query butuh index, sebutkan index-nya ke user.
- Pakai listener real-time hanya di layar yang butuh, dan lepas saat layar ditutup.

## 10. Error handling
- Tangani: tidak ada internet, izin ditolak, dokumen tidak ditemukan, timeout.
- Pesan error ke user ramah dan berbahasa Indonesia. Detail teknis ke log internal saja,
  tanpa data pribadi.
- Operasi tulis idempotent kalau memungkinkan (tombol bayar ditekan dua kali tidak
  membuat dua tagihan).

## 11. Data dan lingkungan
- Pisahkan lingkungan dev/test dan produksi. Jangan uji coba di data produksi.
- Jangan menghapus/mereset data tanpa konfirmasi eksplisit user.
- Data seed/dummy dibuat lewat script terpisah dan jelas ditandai dummy.
- Simpan file rules di repo (misal `firestore.rules`) supaya ikut versi git.

## 12. Urutan kerja backend per fitur
1. Baca `ARCHITECTURE.md`, `DATA_MODEL.md`, `BACKEND_PROGRESS.md`, dan `TODO(backend)` terkait.
2. Rancang/ubah data model, minta persetujuan user.
3. Tulis security rules.
4. Buat model dan repository.
5. Sambungkan ke state, lalu ke UI di area `TODO(backend)` (jangan ubah tampilan).
6. Uji alur utama dan kasus gagal.
7. Hapus komentar `TODO(backend)` yang sudah selesai, update `BACKEND_PROGRESS.md`.