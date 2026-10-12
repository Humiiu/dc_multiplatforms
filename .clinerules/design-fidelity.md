# Design Fidelity Rules — Dian Catering App

Berlaku untuk semua pekerjaan UI/desain. Tujuan: hasil kode harus mendekati pixel-match
dengan desain PNG, bukan sekadar "mirip". Patuhi juga `00-core.md`.

## 1. Sumber kebenaran (source of truth)
- Desain PNG ada di folder: `docs/`
  (`C:\Users\jundi\StudioProjects\dc_multiplatforms\docs`).
- Satu PNG = satu halaman/komponen. Nama file = nama screen (misal `login.png`, `home.png`).
- Kalau kode dan PNG berbeda, PNG yang benar. Jangan mengarang desain sendiri.
- Figma sebelumnya dipakai tool lain tapi sekarang tidak tersedia. Abaikan rujukan Figma
  di log lama. Kalau PNG tampak bertentangan dengan keputusan di log, TANYA user.
- Kalau ada detail yang tidak jelas di PNG, TANYA user. Jangan menebak.
- Jangan membuat halaman baru yang tidak punya PNG (termasuk dashboard admin).

## 2. Plan Mode vs Act Mode
- PLAN MODE tidak bisa membaca gambar. Jangan pernah berpura-pura sudah melihat PNG.
  Di Plan Mode hanya: baca kode, baca file `.md`, susun rencana, dan sebut PNG mana yang
  perlu dibaca nanti di Act Mode.
- ACT MODE: WAJIB membuka dan membaca PNG yang relevan SEBELUM mengubah kode UI apa pun.
  Setelah membaca, tulis dulu Design Spec (poin 3), baru coding.
- Jika PNG tidak bisa dibaca atau tidak ditemukan, STOP dan lapor ke user.

## 3. Design Spec wajib per halaman/komponen
Sebelum coding, ekstrak dari PNG dan tulis ke `docs/design-specs/<nama-screen>.md`:
- **Layout**: urutan section atas ke bawah, alignment, scroll atau fixed.
- **Spacing**: padding luar, jarak antar elemen, margin antar card (logical pixel/dp).
- **Tipografi**: font, ukuran, weight, warna tiap teks (judul, subjudul, body, label, harga).
- **Warna**: hex tiap elemen (background, card, border, teks, tombol, ikon).
- **Shape**: corner radius, tebal border, shadow/elevation.
- **Komponen**: tinggi tombol, ukuran ikon, ukuran avatar/gambar, tinggi input.
- **State**: default, selected, pressed, disabled, error, loading, kosong
  (kalau terlihat atau relevan).
- **Teks persis** yang tampil di desain (bahasa, kapitalisasi, tanda baca).
Nilai yang berupa perkiraan ditandai `(~perkiraan)` supaya bisa dicek user.

## 4. Design token
- Token yang sudah ada di `lib/core/theme.dart`: `AppColors`, `AppRadius`, `AppShadows`,
  `AppTextStyles`. Widget bersama di `lib/ui/shared_widgets.dart`.
- Cocokkan spec dengan token yang ada dulu. Jangan membuat token baru kalau nilainya
  sudah ada atau sangat mirip.
- Nilai baru yang memang dibutuhkan ditambahkan ke token dan dicatat di
  `FRONTEND_PROGRESS.md`. Dilarang hardcode di halaman.
- Palet utama dipakai bersama customer dan admin. Palet admin hanya sekunder dan
  TIDAK boleh menggantikan palet utama.
- Tema minimalist elegan: hindari dekorasi berlebihan, gradient ramai, atau shadow tebal.

## 5. Aturan implementasi
- Perintah "polish halaman X" berarti: baca PNG halaman itu, bandingkan dengan kode,
  lalu perbaiki SEMUA selisih yang ditemukan. User TIDAK perlu menyebut detail perubahan.
  PNG adalah instruksinya. Jangan minta instruksi spesifik. Tanya hanya kalau ada detail
  yang benar-benar tidak jelas di PNG.
- Perintah "polish semua halaman" berarti mengerjakan semua halaman berurutan satu per
  satu, tanpa berhenti di antaranya (lihat `00-core.md` bagian 5).
- Ubah hanya halaman/komponen yang termasuk dalam perintah. Jangan refactor file lain.
- Jangan mengubah logic, state demo, navigasi, dependency, atau komentar `TODO(backend)`.
- Kalau mengubah widget bersama (`shared_widgets.dart`, `theme.dart`), sebutkan halaman
  lain yang terdampak dan cek halaman yang sudah selesai tidak rusak.
- Komponen yang dipakai berulang (card menu, card tagihan, tombol, input) dibuat reusable
  lalu dipakai ulang.
- Jangan menambah elemen yang tidak ada di desain. Jangan menghapus elemen yang ada di desain.
- Aset gambar/vector yang belum tersedia (foto menu, avatar): pakai placeholder lokal dan
  catat sebagai belum selesai. Jangan mengarang aset.

## 6. Verifikasi (wajib sebelum bilang "selesai" untuk tiap halaman)
Checklist per halaman, jawab satu per satu:
- [ ] Urutan section sama dengan PNG
- [ ] Spacing/padding sama
- [ ] Font, ukuran, dan weight teks sama
- [ ] Warna sama persis (hex)
- [ ] Radius, border, shadow sama
- [ ] Teks sama persis
- [ ] Ikon dan gambar sesuai ukuran dan posisi
- [ ] State (selected/aktif/error) sesuai desain
- [ ] Aman di layar kecil dan besar (tidak overflow)
- [ ] `flutter analyze` bersih
Lalu tulis daftar **perbedaan yang masih ada** (jujur). Jangan klaim "pixel-perfect" kalau
belum bisa dibuktikan. Kalau ada screenshot hasil, bandingkan dengan PNG.

## 7. Catatan
- Progress log, komunikasi, dan aturan umum ada di `00-core.md`.
- Fase desain tidak menyentuh backend/Firebase. Backend mengikuti `02-backend-firebase.md`.