# 🍱 Catering Booking App

Aplikasi pemesanan catering berbasis Flutter dengan Firebase untuk siswa SMK.

## ✨ Fitur Utama

- **Autentikasi OTP**: Login/Register menggunakan nomor telepon dengan verifikasi OTP
- **Pemesanan Menu**: Pesan paket catering harian dengan berbagai pilihan menu
- **Keranjang Belanja**: Tambah, edit, dan hapus pesanan sebelum checkout
- **Riwayat Pemesanan**: Lihat semua transaksi yang pernah dilakukan
- **Profil Pengguna**: Kelola informasi pribadi (nama, jurusan, kelas)
- **Multi-platform**: Mendukung Android, iOS, Web, Windows, macOS, dan Linux

## 🏗️ Teknologi

- **Flutter** - UI Framework
- **Riverpod** - State Management
- **Firebase Auth** - Autentikasi OTP
- **Firebase Realtime Database** - Database real-time
- **GoRouter** - Routing dan navigasi

## 📁 Struktur Project

```
lib/
├── core/
│   └── firebase.dart           # Inisialisasi Firebase
├── models/
│   ├── user.dart              # Model data user
│   ├── menu.dart              # Model data menu
│   └── order.dart             # Model data pesanan
├── services/
│   ├── auth_service.dart      # Service autentikasi
│   └── database_service.dart  # Service database
├── screens/
│   ├── auth/
│   │   └── auth_page.dart     # Halaman login/register
│   ├── home/
│   │   └── home_page.dart     # Halaman utama (daftar menu)
│   ├── order/
│   │   └── order_page.dart    # Halaman keranjang
│   ├── checkout/
│   │   └── checkout_page.dart # Halaman checkout
│   ├── history/
│   │   └── history_page.dart  # Riwayat pemesanan
│   └── profile/
│       └── profile_page.dart  # Halaman profil
├── router.dart                # Konfigurasi routing
└── main.dart                  # Entry point aplikasi
```

## 🚀 Setup Project

### 1. Prerequisites

- Flutter SDK (versi 3.0 atau lebih tinggi)
- Dart SDK
- Firebase CLI
- Editor: Android Studio / VS Code

### 2. Clone Repository

```bash
git clone <repository-url>
cd dc_multiplatforms
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Setup Firebase

1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. Enable **Firebase Authentication** (Phone Number Sign-in)
3. Enable **Firebase Realtime Database**
4. Download file konfigurasi:
   - `google-services.json` untuk Android → letakkan di `android/app/`
   - `GoogleService-Info.plist` untuk iOS → letakkan di `ios/Runner/`

5. Inisialisasi Firebase untuk Flutter:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi Firebase
flutterfire configure
```

### 5. Konfigurasi Realtime Database Rules

Buka Firebase Console → Realtime Database → Rules, lalu gunakan rules berikut:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "menus": {
      ".read": true,
      ".write": false
    },
    "orders": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### 6. Tambahkan Data Menu (Dummy)

Buka Firebase Console → Realtime Database → Data, tambahkan struktur berikut.
Menu dikelompokkan per hari kerja (lowercase: `senin`, `selasa`, `rabu`, `kamis`, `jumat`) — lihat `home_page.dart` dan `database_service.dart`:

```json
{
  "menus": {
    "senin": {
      "menu1": {
        "id": "menu1",
        "name": "Paket Nasi + Ayam Goreng",
        "price": 15000,
        "imageUrl": "https://via.placeholder.com/300x200?text=Ayam+Goreng"
      },
      "menu2": {
        "id": "menu2",
        "name": "Paket Nasi + Sayur Asem",
        "price": 13000,
        "imageUrl": "https://via.placeholder.com/300x200?text=Sayur+Asem"
      }
    },
    "selasa": {
      "menu3": {
        "id": "menu3",
        "name": "Paket Nasi + Ikan Bakar",
        "price": 18000,
        "imageUrl": "https://via.placeholder.com/300x200?text=Ikan+Bakar"
      }
    },
    "rabu": {
      "menu4": {
        "id": "menu4",
        "name": "Paket Nasi + Rendang",
        "price": 20000,
        "imageUrl": "https://via.placeholder.com/300x200?text=Rendang"
      }
    },
    "kamis": {},
    "jumat": {}
  }
}
```

> Catatan: `MenuItem` (`lib/models/menu.dart`) hanya menyimpan `id`, `name`, `price`, dan opsional `imageUrl`. Field `description` diabaikan oleh aplikasi.

## 🎯 Cara Menjalankan

### Android/iOS

```bash
flutter run
```

### Web

```bash
flutter run -d chrome
```

### Windows/macOS/Linux

```bash
flutter run -d windows  # atau macos, linux
```

## 📱 Flow Aplikasi

1. **Login/Register**
   - User memasukkan nomor telepon (+62xxx)
   - Sistem mengirim OTP via SMS
   - User memasukkan kode OTP
   - Jika register, isi data tambahan (nama, jurusan, kelas)

2. **Home (Daftar Menu)**
   - Tampilkan semua menu catering
   - User bisa tambah menu ke keranjang

3. **Order (Keranjang)**
   - Lihat semua menu yang dipilih
   - Edit jumlah atau hapus item
   - Lanjut ke checkout

4. **Checkout**
   - Konfirmasi pesanan
   - Proses pembayaran (placeholder)
   - Simpan ke riwayat

5. **History**
   - Lihat semua pesanan yang sudah dilakukan
   - Filter berdasarkan status

6. **Profile**
   - Edit informasi pribadi
   - Logout

## 🧪 Testing

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Check formatting
flutter format --set-exit-if-changed .
```

## 📦 Build Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle (untuk Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ipa --release
```

### Web

```bash
flutter build web --release
```

## 🔧 Troubleshooting

### Firebase Authentication Error

- Pastikan SHA-1 fingerprint sudah ditambahkan di Firebase Console
- Cek apakah Phone Authentication sudah di-enable
- Verifikasi `google-services.json` sudah di tempat yang benar

### Build Error

```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run
```

### OTP Tidak Terkirim

- Pastikan nomor telepon dalam format internasional (+62xxx)
- Cek kuota SMS di Firebase Console
- Untuk testing, gunakan phone number test di Firebase Console

## 🤝 Kontribusi

Pull requests are welcome! Untuk perubahan besar, silakan buka issue terlebih dahulu.

## 📄 License

MIT License - lihat file LICENSE untuk detail.

## 👨‍💻 Developer

Dibuat dengan ❤️ untuk project SMK

---

**Note**: Ini adalah aplikasi demo untuk pembelajaran. Untuk production, tambahkan:
- Error handling yang lebih robust
- Loading states
- Payment gateway integration
- Push notifications
- Analytics
- Testing yang lebih lengkap
