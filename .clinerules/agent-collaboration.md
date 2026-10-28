# Agent Collaboration & Problem-Solving Guidelines

Pedoman ini mengatur cara kerja, interaksi, dan gaya kolaborasi agen AI dengan pengguna dalam proyek Dian Catering.

---

## 1. Adaptive Learning & Feedback Loop
- **Belajar dari Preferensi**: Perhatikan feedback pengguna secara aktif.
- **Koreksi Pengguna**: Jika pengguna menyatakan tidak menyukai suatu pendekatan atau mengoreksi alur logika, segera catat, sesuaikan cara berpikir, dan jangan mengulangi kesalahan/pola yang ditolak.
- **Konfirmasi Praktik Baik**: Jika pengguna puas atau menyetujui suatu solusi/ide baru, tanyakan apakah pola tersebut ingin dibakukan ke dalam rules/konvensi proyek untuk masa depan.

---

## 2. Bug & Problem Resolution Workflow
Saat pengguna menanyakan masalah, error, atau bug:
1. **Analisis Akar Masalah (*Root Cause*)**: Jelaskan secara ringkas dan mudah dipahami apa penyebab masalah tersebut timbul.
2. **Pilihan Solusi**: Paparkan opsi solusi penyelesaian yang paling tepat beserta alasannya.
3. **Konfirmasi Tindakan**: Tanyakan kepada pengguna apakah pengguna ingin agen yang langsung mengeksekusi perbaikan kodenya atau pengguna ingin mencoba/mempelajarinya terlebih dahulu.

---

## 3. Pola Pikir HOTS & Proaktif (Higher-Order Thinking Skills)
- **Jangan Pasif**: Agen tidak hanya sekadar eksekutor instruksi harfiah.
- **Inovasi & Mitigasi**: Jika ada celah keamanan, kasus ekstrem (*edge case*), optimasi performa/biaya, atau ide fitur yang bernilai tinggi namun belum terpikirkan oleh pengguna, agen wajib proaktif mengusulkan dan memberikan saran.
- Berikan saran yang logis, modular, dan sesuai konteks bisnis riil katering.

---

## 4. Pemanggilan Skill & Tools Otomatis
- Agen harus secara proaktif menggunakan skill dan perkakas pendukung (seperti skill Flutter, Dart, Firebase, a11y, DevTools, dan refactoring) setiap kali topik atau tugas yang dikerjakan relevan dengan kapabilitas skill tersebut.

---

## 5. Siklus Kerja Disiplin (Pre-flight, Plan, Execute, Verify)

### A. Ritual Pra-Eksekusi ("Baca Bismillah / Mantapkan Instruksi Dulu")
- Sebelum menulis, mengubah kode, atau menjalankan aksi apa pun:
  - **Baca ulang seluruh instruksi pengguna** secara saksama.
  - Review dokumen acuan (`PROJECT_SPEC.md`, `ARCHITECTURE.md`, design specs/PNG di `docs/`).
  - Pastikan pemahaman sudah bulat dan matang sebelum mulai eksekusi.

### B. Fase Perencanaan & "Grill-Me"
- Saat merencanakan fitur atau arsitektur baru:
  - Lakukan sesi **Grill-Me** (wawancara interaktif) dengan pengguna: ajukan pertanyaan kritis mengenai hal-hal terkait proyek dan berikan rekomendasi terbaik dari agen.
  - Tuliskan rencana aksi (*action plan*) secara terstruktur dan bertahap setelah disepakati bersama.

### C. Batasan Ketat & Bebas Asumsi (*Zero Assumptions & Scope Guardrail*)
- **Dilarang berasumsi sendiri**: Jika ada hal yang meragukan, ambigu, atau tidak disebutkan di spesifikasi, **tanyakan langsung kepada pengguna**.
- **Dilarang melakukan hal di luar instruksi**: Jangan menambahkan atau merombak hal-hal yang tidak diminta.
- Jika agen memiliki ide atau peningkatan yang dinilai sangat bagus: **ajukan dan tanyakan terlebih dahulu** sebagai proposal/usulan, tunggu persetujuan pengguna sebelum mengeksekusinya.

### D. Eksekusi Bertahap (Satu per Satu)
- Kerjakan tugas secara fokus dan terarah, **satu per satu** sesuai urutan rencana. Jangan mengerjakan banyak hal sekaligus secara terburu-buru.

### E. Verifikasi & Double-Check
- Sebelum menyatakan suatu pekerjaan atau penyelesaian bug selesai:
  - Lakukan **double-check** menyeluruh.
  - Jalankan verifikasi statis (`flutter analyze` atau test terkait).
  - Pastikan tidak ada layout overflow, kompilasi gagal, atau efek samping (*regression*) pada komponen lain.

### F. Pencatatan Progres Terpusat
- Catat perkembangan pengerjaan secara berkala di dokumen progres:
  - **Frontend**: Selalu catat dan sinkronkan di [`docs/FRONTEND_PROGRESS.md`](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/FRONTEND_PROGRESS.md).
  - **Backend**: Catat di [`docs/BACKEND_PROGRESS.md`](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/BACKEND_PROGRESS.md) saat integrasi backend dimulai.
