# DiAn Catering

Aplikasi frontend Flutter untuk alur pemesanan katering pada Android dan iOS.
Tampilan saat ini mengikuti referensi layar Login/Register, Home, Order, History,
Checkout, dan Profile.

## Menjalankan aplikasi

```sh
flutter pub get
flutter run
```

Untuk membuat Android debug APK:

```sh
flutter build apk --debug
```

## Status integrasi

Antarmuka saat ini memakai state dan data contoh lokal. Login, pembuatan pesanan,
dan pembayaran belum terhubung ke backend serta tidak memproses transaksi.
Model, provider, dan service backend yang sudah ada tetap tersedia untuk tahap
integrasi berikutnya. Antarmuka admin berada di luar aplikasi Flutter ini.
