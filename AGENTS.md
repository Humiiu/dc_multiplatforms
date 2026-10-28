# Panduan & Aturan Proyek Dian Catering (Antigravity Rules)

Rules ini berlaku untuk seluruh proses development aplikasi Dian Catering (desain, frontend, backend, bugfix, refactor) dan WAJIB DIBACA SERTA DIPATUHI OLEH SETIAP MODEL (Gemini, Claude Opus/Sonnet, GPT, dll).

---

## 1. Tentang Proyek & Spesifikasi Kunci
- **Aplikasi**: Dian Catering (Customer App: pesan menu, bayar/ngutang; Admin Dashboard: kelola menu, omzet, siswa, tagihan, absen).
- **Target Platform**: Flutter multiplatform (Android Play Store, iOS App Store, Web PWA untuk pelanggan insidental, dan Web Admin).
- **Model Bisnis**: Senin–Jumat, harga flat Rp 20.000 / box. Menu mingguan rolling (hanya lauk utama yang di-display). Cut-off pemesanan malam hari maks 21:30 WIB.
- **Pay Later (Ngutang)**: Maks plafon Rp 100.000, wajib konfirmasi via WhatsApp admin, status pending hingga di-ACC di Web Admin.
- **Proteksi Finansial (PIN Owner)**: Dashboard admin dipakai bersama karyawan. Namun halaman laporan omzet, modal, dan laba dilindungi **PIN/Password Khusus Owner** dengan fitur *auto-lock*.
- **Referensi Detail**: [PROJECT_SPEC.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/PROJECT_SPEC.md) & [ARCHITECTURE.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/ARCHITECTURE.md).

---

## 2. Siklus Kerja Disiplin & Instruction Set (WAJIB DIPATUHI)

### A. Ritual Pra-Eksekusi ("Baca Bismillah / Mantapkan Instruksi Dulu")
- Sebelum mengubah kode, membuat file, atau menjalankan perintah apa pun:
  - **Wajib membaca dan me-review kembali seluruh instruksi pengguna** secara saksama.
  - Review dokumen acuan (`PROJECT_SPEC.md`, `ARCHITECTURE.md`, design specs/PNG di `docs/`, dan progress log).
  - Mantapkan pemahaman terlebih dahulu, jangan tergesa-gesa menulis kode tanpa arah yang pasti.

### B. Planning & "Grill-Me" Protocol
- Saat diminta merencanakan fitur atau arsitektur baru:
  - **Wajib lakukan sesi Grill-Me (wawancara interaktif)**: Ajukan pertanyaan kritis terkait proyek kepada pengguna, berikan opsi arsitektur, dan sertakan rekomendasi terbaik.
  - Tuliskan rencana aksi (*action plan*) secara terstruktur dan bertahap setelah dimantapkan bersama pengguna.

### C. Zero Assumptions & Scope Guardrail (Dilarang Berasumsi)
- **Dilarang keras berasumsi sendiri** jika menemukan instruksi yang ambigu atau belum jelas. **Tanyakan langsung ke pengguna!**
- **Dilarang melakukan hal-hal di luar perintah pengguna** (jangan menambah dependency, mengubah file sembarangan, atau membuat fitur ekstra tanpa diminta).
- Jika memiliki ide bagus atau inovatif: **usulkan dan tanyakan terlebih dahulu**, jangan dieksekusi sebelum disetujui pengguna.

### D. Eksekusi Bertahap (Satu per Satu)
- Kerjakan tugas secara bertahap, **satu per satu** sesuai urutan rencana. Dilarang borongan atau melompati langkah tanpa kendali.

### E. Double Check & Verifikasi Wajib
- Sebelum menyatakan suatu tugas atau perbaikan selesai:
  - Lakukan **double-check** menyeluruh terhadap kode.
  - Jalankan verifikasi statis (`flutter analyze` atau test terkait).
  - Pastikan 0 error, tidak ada layout overflow, dan tidak ada efek samping/regresi.

### F. Pencatatan Progres Terpusat
- Catat setiap progres yang telah dicapai:
  - **Frontend**: Wajib dicatat dan disinkronkan di [`docs/FRONTEND_PROGRESS.md`](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/FRONTEND_PROGRESS.md).
  - **Backend**: Dicatat di [`docs/BACKEND_PROGRESS.md`](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/docs/BACKEND_PROGRESS.md) saat integrasi backend dimulai.

### G. Pengingat Perintah Pengujian Emulator (WAJIB DIBERIKAN SETIAP SELESAI REVISI KODE)
- Setiap kali selesai melakukan revisi kode, perbaikan bug, atau UI polish:
  - **Wajib selalu menyertakan petunjuk command pengujian emulator** di akhir respons agar pengguna tidak lupa:
    1. Perintah launch emulator HP: `flutter emulators --launch Medium_Phone`
    2. Perintah run: `flutter run`
    3. Shortcut Hot Reload: tekan `r` pada terminal aktif untuk melihat perubahan secara instan.

### H. Protokol Git Commit & Backup Antar Perangkat (WAJIB SETIAP MILESTONE / PROGRES)
- Setiap kali suatu task/revisi/fitur selesai dan lulus verifikasi (`flutter analyze` & `flutter test` bersih):
  - **Wajib lakukan Git Commit** dengan gaya pesan: **Bahasa Indonesia santai/gaul, huruf kecil semua di awal (tanpa kapital), yang penting ada inti informasinya** (contoh: `revisi desain home page`, `benerin navbar history`, `gatau, buat ganti device`, `pasang pull to refresh di home`).
  - *Catatan*: Gaya santai dan huruf kecil ini KHUSUS untuk pesan `git commit` saja. Output respons chat asisten TETAP rapi, profesional, dan terstruktur seperti biasa.
  - Ini memastikan tersedianya checkpoint aman kapan pun dibutuhkan rollback / reverse jika ada bug fatal.
  - Berikan pengingat atau jalankan push (`git push origin master`) agar kode tersimpan aman di cloud repository GitHub (`https://github.com/Humiiu/dc_multiplatforms`) untuk sinkronisasi antar perangkat ngoding.

---

## 3. Protokol Penanganan Masalah & Diagnosa Bug
Saat menangani bug, error, atau kendala teknis:
1. Analisis dan jelaskan terlebih dahulu **akar masalah (root cause)** secara jelas dan ringkas.
2. Paparkan opsi **solusi penyelesaiannya**.
3. **Konfirmasikan ke pengguna**: Tanyakan apakah pengguna ingin agen yang mengimplementasikan perbaikannya secara langsung atau hanya ingin saran/panduan untuk dieksplorasi mandiri.

---

## 4. Fase Kerja & Batasan Scope
- **FASE DESAIN / UI POLISH**:
  - Hanya ubah tampilan (layout, warna, tipografi, card, spacing) sesuai acuan PNG di `docs/`.
  - Jangan ubah business logic, state/dependency tanpa izin, atau menghapus penanda backend.
- **FASE BACKEND**:
  - Implementasi integrasi Firebase di area bertanda `TODO(backend)`.
  - Jangan merombak tema, layout visual, atau design token saat mengerjakan backend.
- Pertahankan komentar `TODO(backend)` sampai integrasinya selesai dan teruji.

---

## 5. Pemanggilan Skill Otomatis
- Secara otomatis buka dan terapkan panduan skill relevan (Flutter layout, routing, Firebase Firestore, Auth, Rules, DevTools) setiap kali topik terkait dibahas tanpa menunggu diperintah manual.

Referensi modular tambahan:
- [.agents/rules/core.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/.agents/rules/core.md)
- [.agents/rules/agent-collaboration.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/.agents/rules/agent-collaboration.md)
- [.agents/rules/design-fidelity.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/.agents/rules/design-fidelity.md)
- [.agents/rules/backend-firebase.md](file:///c:/Users/jundi/StudioProjects/dc_multiplatforms/.agents/rules/backend-firebase.md)

