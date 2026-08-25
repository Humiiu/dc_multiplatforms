# 🔥 Firebase Setup Guide

Panduan lengkap untuk mengkonfigurasi Firebase pada aplikasi Catering Booking.

## 📋 Prerequisites

- Akun Google
- Flutter SDK terinstal
- Firebase CLI terinstal

## 🚀 Langkah-langkah Setup

### 1. Membuat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik **Add project** atau **Create a project**
3. Masukkan nama project: `catering-booking-app`
4. Enable Google Analytics (opsional)
5. Klik **Create project**

### 2. Enable Firebase Authentication

1. Di sidebar, pilih **Authentication**
2. Klik **Get started**
3. Pilih tab **Sign-in method**
4. Enable **Phone** authentication:
   - Klik pada "Phone"
   - Toggle switch ke ON
   - Klik **Save**

#### Setup Phone Authentication untuk Testing

Untuk testing tanpa menggunakan SMS real:

1. Di halaman **Sign-in method**, scroll ke bawah ke bagian **Phone numbers for testing**
2. Tambahkan nomor test dan kode OTP:
   - Phone: `+62 812 3456 7890`
   - Code: `123456`
3. Klik **Add**

### 3. Enable Firebase Realtime Database

1. Di sidebar, pilih **Realtime Database**
2. Klik **Create Database**
3. Pilih lokasi server (contoh: `asia-southeast1`)
4. Pilih mode **Start in test mode** (untuk development)
5. Klik **Enable**

#### Setup Database Rules

Ganti rules dengan:

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
        ".write": "$uid === auth.uid",
        ".indexOn": ["createdAt"]
      }
    }
  }
}
```

**Penjelasan Rules:**
- `users`: Setiap user hanya bisa baca/tulis data mereka sendiri
- `menus`: Semua orang bisa baca, hanya admin yang bisa tulis (via console)
- `orders`: User hanya bisa baca/tulis pesanan mereka sendiri

### 4. Tambahkan Data Menu Awal

1. Di Realtime Database, klik **Data** tab
2. Klik ikon **+** di root
3. Masukkan:
   - Name: `menus`
   - Klik **+** untuk menambah child

Copy JSON berikut ke database:

```json
{
  "menus": {
    "menu1": {
      "id": "menu1",
      "name": "Paket Nasi + Ayam Goreng",
      "description": "Nasi putih, ayam goreng krispi, sayur asem, kerupuk, sambal",
      "price": 15000,
      "imageUrl": "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=300"
    },
    "menu2": {
      "id": "menu2",
      "name": "Paket Nasi + Ikan Bakar",
      "description": "Nasi putih, ikan bakar bumbu kecap, sayur bayam, sambal terasi",
      "price": 18000,
      "imageUrl": "https://images.unsplash.com/photo-1580217593608-61931cefc821?w=300"
    },
    "menu3": {
      "id": "menu3",
      "name": "Paket Nasi + Rendang",
      "description": "Nasi putih, rendang sapi empuk, perkedel kentang, acar timun",
      "price": 20000,
      "imageUrl": "https://images.unsplash.com/photo-1555126634-323283e090fa?w=300"
    },
    "menu4": {
      "id": "menu4",
      "name": "Paket Nasi + Soto Ayam",
      "description": "Nasi putih, soto ayam santan, perkedel, kerupuk, sambal",
      "price": 16000,
      "imageUrl": "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=300"
    },
    "menu5": {
      "id": "menu5",
      "name": "Paket Nasi + Tempe Mendoan",
      "description": "Nasi putih, tempe mendoan, tahu isi, sayur lodeh, kerupuk",
      "price": 12000,
      "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300"
    }
  }
}
```

### 5. Setup Firebase untuk Android

#### a. Register Android App

1. Di Project Overview, klik ikon Android
2. Masukkan Android package name:
   - Package name: `com.example.dc_multiplatforms`
   - App nickname: `Catering Booking Android` (opsional)
3. Klik **Register app**

#### b. Download google-services.json

1. Download file `google-services.json`
2. Copy ke folder `android/app/`

#### c. Add SHA-1 Fingerprint (untuk production)

Generate SHA-1:

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (setelah dibuat)
keytool -list -v -keystore /path/to/release.keystore -alias your-alias
```

Tambahkan SHA-1 ke Firebase Console → Project Settings → Your apps → Android apps → Add fingerprint

#### d. Konfigurasi build.gradle

File `android/build.gradle` sudah dikonfigurasi dengan:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

File `android/app/build.gradle` sudah dikonfigurasi dengan:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 6. Setup Firebase untuk iOS

#### a. Register iOS App

1. Di Project Overview, klik ikon iOS
2. Masukkan iOS bundle ID:
   - Bundle ID: `com.example.dcMultiplatforms`
   - App nickname: `Catering Booking iOS` (opsional)
3. Klik **Register app**

#### b. Download GoogleService-Info.plist

1. Download file `GoogleService-Info.plist`
2. Drag file ke Xcode project di `Runner` folder
3. Pastikan "Copy items if needed" ter-check

### 7. Setup Firebase untuk Web

#### a. Register Web App

1. Di Project Overview, klik ikon Web (</>)
2. Masukkan app nickname: `Catering Booking Web`
3. Enable Firebase Hosting (opsional)
4. Klik **Register app**

#### b. Copy Firebase Config

Copy konfigurasi yang diberikan dan update file `web/index.html`:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js";
  
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    databaseURL: "https://YOUR_PROJECT.firebaseio.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };

  initializeApp(firebaseConfig);
</script>
```

### 8. Install FlutterFire CLI

```bash
# Install
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### 9. Configure FlutterFire

```bash
# Login ke Firebase
firebase login

# Configure Flutter project
flutterfire configure
```

Pilih:
- Select Firebase project: `catering-booking-app`
- Select platforms: Android, iOS, Web (pilih sesuai kebutuhan)

Ini akan generate file `lib/firebase_options.dart` secara otomatis.

### 10. Test Authentication

#### Test dengan Nomor Real

1. Jalankan app: `flutter run`
2. Masukkan nomor telepon real (+62xxx)
3. Tunggu SMS OTP
4. Masukkan kode OTP

#### Test dengan Test Phone Number

1. Gunakan nomor test yang sudah didaftarkan: `+6281234567890`
2. Masukkan kode test: `123456`

## 📊 Monitoring

### Authentication Users

- Firebase Console → Authentication → Users
- Lihat daftar user yang sudah registrasi

### Database Data

- Firebase Console → Realtime Database → Data
- Monitor data real-time

### Usage & Billing

- Firebase Console → Usage and billing
- Cek kuota authentication dan database

## 🔒 Security Best Practices

1. **Never commit Firebase config files:**
   - `google-services.json`
   - `GoogleService-Info.plist`
   - Sudah ada di `.gitignore`

2. **Update Database Rules untuk Production:**
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
         ".read": "auth != null",
         ".write": false
       },
       "orders": {
         "$uid": {
           ".read": "$uid === auth.uid",
           ".write": "$uid === auth.uid && newData.child('userId').val() === auth.uid"
         }
       }
     }
   }
   ```

3. **Enable App Check** (untuk production):
   - Proteksi dari abuse
   - Firebase Console → App Check

4. **Set Budget Alerts:**
   - Firebase Console → Usage and billing → Budget alerts
   - Set alert untuk mencegah overage

## 🐛 Troubleshooting

### Firebase initialization failed

```bash
# Re-run configuration
flutterfire configure --force
```

### OTP tidak terkirim

- Cek apakah Phone Authentication sudah enabled
- Verifikasi nomor dalam format internasional (+62)
- Cek kuota SMS di Firebase Console

### Database permission denied

- Cek database rules
- Pastikan user sudah authenticated
- Verifikasi UID di rules

### Android build error: google-services.json

```bash
# Verify file location
ls android/app/google-services.json

# Rebuild
flutter clean
flutter pub get
flutter build apk
```

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)

---

**Note:** Untuk production, selalu gunakan environment yang terpisah (dev, staging, production) dengan Firebase projects yang berbeda.
