# Dian Catering Telegram Dev Bridge 📱💻

Jembatan interaksi remote antara Telegram di HP Anda dan workspace proyek di PC.

## Cara Menjalankan:
1. Klik ganda file `start_bot.bat` (atau jalankan `python bot.py` di terminal).
2. Bot akan langsung terhubung ke Telegram tanpa perlu konfigurasi port forwarding atau IP publik.

## Perintah di Telegram:
* `/start` atau `/help` : Menampilkan menu panduan.
* `/ss` atau `/screenshot` : Menangkap layar Android emulator aktif (`Medium_Phone`) dan langsung mengirim foto ke chat Telegram.
* `/analyze` : Menjalankan verifikasi `flutter analyze` di PC dan mengirim laporannya.
* `/git` : Memeriksa branch, status perubahan file, dan log commit terakhir.
* `/run <command>` : Mengeksekusi perintah terminal PowerShell di PC langsung dari HP (contoh: `/run git status`, `/run dir`).
* **Chat Biasa** : Mengirim instruksi ke AI Antigravity untuk coding atau tanya jawab proyek (memerlukan `gemini_api_key` di `config.json`).

