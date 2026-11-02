# Data Model — Dian Catering App (Firebase Realtime Database)

Dokumen ini adalah sumber kebenaran struktur data aplikasi Dian Catering yang menggunakan **Firebase Realtime Database (RTDB)** dan **Firebase Authentication**.

---

## 1. Firebase Authentication
* **Mekanisme Login**: Username & Password.
* **Email Masking Virtual**: `${username.trim().toLowerCase()}@diancatering.app` (username dipetakan ke email virtual di balik layar tanpa perlu input email fisik dari pengguna).
* **Security**: Password di-hash dan dikelola secara aman oleh Firebase Auth, tidak disimpan dalam plaintext di database.

---

## 2. Struktur Tree Realtime Database (`/`)

```json
{
  "users": {
    "<uid>": {
      "uid": "string",
      "username": "string",
      "name": "string",
      "phone": "string",
      "kelas": "X | XI | XII",
      "jurusan": "RPL | DKV | ANM | BC | TKJ | GD",
      "role": "user | admin",
      "photoUrl": "string | null",
      "createdAt": "number (timestamp)"
    }
  },
  "usernames": {
    "<username_lowercase>": {
      "uid": "<uid>"
    }
  },
  "phones": {
    "<normalized_phone>": {
      "uid": "<uid>"
    }
  },
  "menus": {
    "<menu_id>": {
      "id": "string",
      "day": "Senin | Selasa | Rabu | Kamis | Jumat",
      "title": "string",
      "description": "string",
      "imageUrl": "string | null",
      "price": 20000,
      "isAvailable": true,
      "weekNumber": "number"
    }
  },
  "orders": {
    "<order_id>": {
      "id": "string",
      "userId": "<uid>",
      "userName": "string",
      "userPhone": "string",
      "userClass": "string",
      "userMajor": "string",
      "week": "string (misal: 'Oktober, Minggu 2')",
      "date": "string (format: '27 Okt 2026 • 11:06 WIB')",
      "days": ["Senin", "Selasa"],
      "amount": "number (Rp 20.000 per hari terpilih)",
      "payment": "string ('QRIS' | 'Pay Later' | 'Transfer BCA' | 'Transfer Mandiri')",
      "isPaid": "boolean",
      "status": "string ('pending' | 'confirmed' | 'rejected' | 'completed')",
      "createdAt": "number (timestamp ms)",
      "paidAt": "number | null"
    }
  },
  "user_orders": {
    "<uid>": {
      "<order_id>": true
    }
  },
  "debts": {
    "<uid>": {
      "amount": "number (total hutang saat ini, max 100000)",
      "limit": 100000,
      "lastUpdated": "number (timestamp ms)"
    }
  }
}
```

---

## 3. Kamus Data & Validasi

### A. Node `users/<uid>`
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `uid` | String | Ya | Firebase Auth UID |
| `username` | String | Ya | Unik, lowercase/alphanumeric, min 3 karakter |
| `name` | String | Ya | Nama lengkap siswa / admin |
| `phone` | String | Ya | Nomor WhatsApp aktif (+62 / 08xx dinormalisasi) |
| `kelas` | String | Ya | Pilihan: `X`, `XI`, `XII` |
| `jurusan` | String | Ya | Pilihan: `RPL`, `DKV`, `ANM`, `BC`, `TKJ`, `GD` |
| `role` | String | Ya | `user` (siswa) atau `admin` (pengelola katering) |
| `photoUrl` | String? | Tidak | URL foto profil dari Firebase Storage |
| `createdAt` | Number | Ya | Server timestamp milidetik |

### B. Index Pencarian Cepat
* `usernames/<username_lowercase>`: Untuk validasi ketersediaan username (*uniqueness check*) saat registrasi dan lookup cepat.
* `phones/<normalized_phone>`: Untuk validasi nomor telepon ganda.

### C. Node `orders/<order_id>`
| Field | Tipe | Keterangan |
|---|---|---|
| `amount` | Number | Flat Rp 20.000 / hari (contoh 2 hari = 40.000) |
| `payment` | String | `QRIS`, `Pay Later`, `Transfer BCA`, `Transfer Mandiri` |
| `isPaid` | Boolean | `true` jika lunas, `false` jika belum lunas / Pay Later |
| `status` | String | `pending` (menunggu konfirmasi), `confirmed` (diterima), `rejected` (ditolak), `completed` (selesai) |

---

## 4. Security Rules (Realtime Database)
* `users`: Siswa hanya dapat membaca/mengubah data miliknya sendiri. Admin memiliki akses penuh.
* `menus`: Dapat dibaca oleh semua user yang sudah login. Hanya admin yang dapat membuat/mengedit menu.
* `orders`: Siswa hanya dapat membaca pesanan dengan `userId == auth.uid`. Admin dapat membaca dan mengubah status semua order.
* `debts`: Siswa dapat membaca status tagihan miliknya. Perubahan saldo hutang divalidasi dengan plafon Rp 100.000.

