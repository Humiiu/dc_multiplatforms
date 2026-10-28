# Spesifikasi Bisnis & Visi Proyek – Dian Catering

Dokumen ini mendokumentasikan model bisnis, alur kerja operasional, dan arsitektur fitur aplikasi Dian Catering berdasarkan visi owner.

---

## 1. Model Bisnis & Operasional Katering
* **Jadwal Layanan**: Senin sampai Jumat (hari sekolah aktif).
* **Harga Flat**: **Rp 20.000 / box** (harga tetap dan terjangkau untuk siswa).
* **Menu Mingguan**:
  - Menu dipilih dan ditentukan oleh Owner secara bergulir tiap minggu.
  - Tampilan menu di aplikasi siswa difokuskan pada **Lauk / Menu Utama** saja (sayur dan menu pendamping tidak perlu di-display).
* **Batas Waktu Order (Cut-Off Time)**:
  - Siswa dapat memesan malam hari untuk konsumsi besok hari.
  - Batas maksimal pemesanan adalah pukul **21:30 WIB**. Pesanan lewat dari jam 21:30 ditolak untuk hari esoknya.

---

## 2. Aturan Pay Later (Ngutang)
* **Batas Maksimal Plafon**: Maksimal saldo utang siswa adalah **Rp 100.000**.
* **Alur Pengajuan**:
  1. Siswa memilih opsi pembayaran *Pay Later* di aplikasi.
  2. Siswa wajib menghubungi WhatsApp Admin terlebih dahulu untuk konfirmasi alasan/izin ngutang.
  3. Status order di aplikasi tetap **Pending Verification** (menggantung sementara).
  4. Admin memeriksa chat WhatsApp dan meng-ACC pesanan tersebut melalui **Web Admin Dashboard**.
  5. Setelah di-ACC, status order berubah menjadi aktif/diterima dapur.

---

## 3. Akun Pengguna & Autentikasi Siswa
* **Data Registrasi Siswa**:
  - `Username`
  - `Nama Lengkap`
  - `Kelas`
  - `Jurusan`
  - `Password`
* **Metode Login**: Menggunakan kombinasi `Username` dan `Password`.

---

## 4. Arsitektur Multiplatform & Target Rilis
1. **Mobile App (Flutter: Android Play Store & iOS App Store)**:
   - Target utama untuk siswa / pelanggan tetap katering harian.
2. **Web App (Flutter Web / PWA)**:
   - Alternatif untuk siswa/pelanggan insidental yang malas mendownload aplikasi mobile.
3. **Web Admin Dashboard**:
   - Platform kerja operasional untuk Admin/Owner dan Karyawan.

---

## 5. Fitur Web Admin Dashboard & Proteksi Finansial (PIN Owner)
### A. Tampilan Bersama (Shared Workspace)
* Karyawan dan Owner menggunakan Web Admin yang sama untuk aktivitas operasional:
  - Mengelola daftar pesanan masuk dan rekap total box per hari.
  - Checklist kehadiran/serah terima makanan ke siswa.
  - Mengatur menu harian/mingguan dari bank template menu serta upload gambar lauk.

### B. Proteksi Finansial (PIN / Password Khusus Owner)
* Karyawan **TIDAK BOLEH** melihat data finansial, modal, margin, maupun total keuntungan katering.
* **Mekanisme**:
  - Menu/tombol *"Laporan Finansial & Keuntungan"* di Web Admin dilindungi oleh **PIN / Password Khusus Owner**.
  - Saat tombol ditekan, modal autentikasi muncul: *"Masukkan PIN Owner"*.
  - Hanya jika PIN valid, grafik omzet, modal belanja mingguan, total box terjual, dan keuntungan bersih akan terbuka.
  - **Auto-Lock Security**: Setelah sesi ditutup atau dalam jeda inaktivitas tertentu, halaman finansial terkunci kembali secara otomatis demi privasi saat perangkat ditinggal.

### C. Fitur Template Menu & Rolling
* Owner/Admin dapat memasukkan bank data menu lauk utama.
* Fitur *rolling* / pemilihan cepat untuk menentukan menu di minggu ke-X dan hari apa saja.
* Input foto menu agar tampil menarik di aplikasi siswa dan web.

