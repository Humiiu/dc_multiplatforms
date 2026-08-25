# 📊 API & Data Structure Documentation

Dokumentasi lengkap struktur data dan API yang digunakan dalam aplikasi Catering Booking.

## 🗄️ Database Structure

### Firebase Realtime Database Schema

```
root/
├── users/
│   └── {userId}/
│       ├── uid: string
│       ├── phone: string
│       ├── name: string
│       ├── jurusan: string
│       └── kelas: string
├── menus/
│   └── {menuId}/
│       ├── id: string
│       ├── name: string
│       ├── description: string
│       ├── price: number
│       └── imageUrl: string
└── orders/
    └── {userId}/
        └── {orderId}/
            ├── id: string
            ├── userId: string
            ├── items: array
            │   └── {index}/
            │       ├── menuId: string
            │       ├── menuName: string
            │       ├── price: number
            │       └── quantity: number
            ├── totalPrice: number
            ├── status: string
            └── createdAt: number (timestamp)
```

## 📋 Data Models

### 1. User Model

**Path:** `lib/models/user.dart`

```dart
class AppUser {
  final String uid;
  final String phone;
  final String name;
  final String jurusan;
  final String kelas;

  AppUser({
    required this.uid,
    required this.phone,
    required this.name,
    required this.jurusan,
    required this.kelas,
  });

  // Convert from JSON
  factory AppUser.fromJson(Map<String, dynamic> json);
  
  // Convert to JSON
  Map<String, dynamic> toJson();
}
```

**Example Data:**
```json
{
  "uid": "abc123xyz",
  "phone": "+628123456789",
  "name": "Budi Santoso",
  "jurusan": "RPL",
  "kelas": "XI"
}
```

**Field Descriptions:**
- `uid`: Unique user ID dari Firebase Auth
- `phone`: Nomor telepon dalam format internasional
- `name`: Nama lengkap siswa
- `jurusan`: Jurusan (RPL, DKV, TKJ, dll)
- `kelas`: Tingkat kelas (X, XI, XII)

---

### 2. Menu Model

**Path:** `lib/models/menu.dart`

```dart
class Menu {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Convert from JSON
  factory Menu.fromJson(String id, Map<String, dynamic> json);
  
  // Convert to JSON
  Map<String, dynamic> toJson();
}
```

**Example Data:**
```json
{
  "id": "menu1",
  "name": "Paket Nasi + Ayam Goreng",
  "description": "Nasi putih, ayam goreng krispi, sayur asem, kerupuk",
  "price": 15000,
  "imageUrl": "https://example.com/ayam-goreng.jpg"
}
```

**Field Descriptions:**
- `id`: Unique identifier untuk menu
- `name`: Nama menu/paket
- `description`: Deskripsi detail isi paket
- `price`: Harga dalam Rupiah (integer)
- `imageUrl`: URL gambar menu

---

### 3. Order Model

**Path:** `lib/models/order.dart`

```dart
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final int totalPrice;
  final String status;
  final int createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // Convert from JSON
  factory Order.fromJson(String id, Map<String, dynamic> json);
  
  // Convert to JSON
  Map<String, dynamic> toJson();
}

class OrderItem {
  final String menuId;
  final String menuName;
  final int price;
  final int quantity;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;

  // Convert from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json);
  
  // Convert to JSON
  Map<String, dynamic> toJson();
}
```

**Example Data:**
```json
{
  "id": "order123",
  "userId": "abc123xyz",
  "items": [
    {
      "menuId": "menu1",
      "menuName": "Paket Nasi + Ayam Goreng",
      "price": 15000,
      "quantity": 2
    },
    {
      "menuId": "menu3",
      "menuName": "Paket Nasi + Rendang",
      "price": 20000,
      "quantity": 1
    }
  ],
  "totalPrice": 50000,
  "status": "completed",
  "createdAt": 1724499358916
}
```

**Field Descriptions:**

Order:
- `id`: Unique identifier untuk order
- `userId`: ID user yang membuat order
- `items`: Array dari OrderItem
- `totalPrice`: Total harga semua item
- `status`: Status order (`pending`, `completed`, `cancelled`)
- `createdAt`: Timestamp (milliseconds since epoch)

OrderItem:
- `menuId`: Reference ke menu
- `menuName`: Nama menu (denormalized untuk performa)
- `price`: Harga per item
- `quantity`: Jumlah item yang dipesan

---

## 🔌 Services API

### 1. AuthService

**Path:** `lib/services/auth_service.dart`

#### Methods

##### `signInWithPhone(String phoneNumber)`
Mengirim OTP ke nomor telepon.

**Parameters:**
- `phoneNumber`: Nomor telepon dalam format internasional (contoh: `+628123456789`)

**Returns:** `Future<void>`

**Throws:** `Exception` jika verifikasi gagal

**Example:**
```dart
await ref.read(authServiceProvider).signInWithPhone('+628123456789');
```

---

##### `verifyCode(String smsCode)`
Verifikasi kode OTP yang diterima.

**Parameters:**
- `smsCode`: Kode 6 digit dari SMS

**Returns:** `Future<User?>` - Firebase User jika berhasil

**Throws:** `Exception` jika verifikasi gagal

**Example:**
```dart
final user = await ref.read(authServiceProvider).verifyCode('123456');
if (user != null) {
  print('Login berhasil: ${user.uid}');
}
```

---

##### `registerUser(...)`
Menyimpan data user tambahan setelah registrasi.

**Parameters:**
- `uid`: User ID dari Firebase Auth
- `phone`: Nomor telepon
- `name`: Nama lengkap
- `jurusan`: Jurusan siswa
- `kelas`: Kelas siswa

**Returns:** `Future<void>`

**Example:**
```dart
await ref.read(authServiceProvider).registerUser(
  uid: user.uid,
  phone: '+628123456789',
  name: 'Budi Santoso',
  jurusan: 'RPL',
  kelas: 'XI',
);
```

---

##### `authStateChanges()`
Stream untuk mendengarkan perubahan status autentikasi.

**Returns:** `Stream<User?>`

**Example:**
```dart
ref.read(authServiceProvider).authStateChanges().listen((user) {
  if (user != null) {
    print('User logged in: ${user.uid}');
  } else {
    print('User logged out');
  }
});
```

---

### 2. DatabaseService

**Path:** `lib/services/database_service.dart`

#### Methods

##### `setUser(String uid, AppUser user)`
Menyimpan atau update data user.

**Parameters:**
- `uid`: User ID
- `user`: Object AppUser

**Returns:** `Future<void>`

**Example:**
```dart
final user = AppUser(
  uid: 'abc123',
  phone: '+628123456789',
  name: 'Budi Santoso',
  jurusan: 'RPL',
  kelas: 'XI',
);
await db.setUser('abc123', user);
```

---

##### `getUser(String uid)`
Mengambil data user berdasarkan UID.

**Parameters:**
- `uid`: User ID

**Returns:** `Future<AppUser?>`

**Example:**
```dart
final user = await db.getUser('abc123');
if (user != null) {
  print('Nama: ${user.name}');
}
```

---

##### `getMenusStream()`
Stream untuk mendapatkan semua menu.

**Returns:** `Stream<List<Menu>>`

**Example:**
```dart
db.getMenusStream().listen((menus) {
  print('Total menu: ${menus.length}');
  for (var menu in menus) {
    print('${menu.name}: Rp ${menu.price}');
  }
});
```

---

##### `addOrder(String userId, Order order)`
Menambahkan order baru.

**Parameters:**
- `userId`: User ID
- `order`: Object Order

**Returns:** `Future<void>`

**Example:**
```dart
final order = Order(
  id: 'order123',
  userId: 'abc123',
  items: [
    OrderItem(
      menuId: 'menu1',
      menuName: 'Paket Nasi + Ayam Goreng',
      price: 15000,
      quantity: 2,
    ),
  ],
  totalPrice: 30000,
  status: 'completed',
  createdAt: DateTime.now().millisecondsSinceEpoch,
);
await db.addOrder('abc123', order);
```

---

##### `getOrdersStream(String userId)`
Stream untuk mendapatkan semua order user.

**Parameters:**
- `userId`: User ID

**Returns:** `Stream<List<Order>>`

**Example:**
```dart
db.getOrdersStream('abc123').listen((orders) {
  print('Total pesanan: ${orders.length}');
  for (var order in orders) {
    print('Order ${order.id}: Rp ${order.totalPrice}');
  }
});
```

---

## 🔐 Authentication Flow

### 1. Login Flow

```
User Input Phone
       ↓
signInWithPhone(phone)
       ↓
Firebase sends OTP
       ↓
User Input OTP
       ↓
verifyCode(otp)
       ↓
[Success] → Navigate to Home
[Failed] → Show Error
```

### 2. Registration Flow

```
User Input Phone
       ↓
signInWithPhone(phone)
       ↓
Firebase sends OTP
       ↓
User Input OTP + Additional Info
       ↓
verifyCode(otp)
       ↓
registerUser(uid, phone, name, jurusan, kelas)
       ↓
Navigate to Home
```

---

## 🛒 Order Flow

### 1. Create Order Flow

```
Browse Menus (HomePage)
       ↓
Add to Cart
       ↓
View Cart (OrderPage)
       ↓
Adjust Quantities
       ↓
Proceed to Checkout
       ↓
Confirm Order (CheckoutPage)
       ↓
addOrder(userId, order)
       ↓
Navigate to History
```

### 2. View History Flow

```
Open History Page
       ↓
getOrdersStream(userId)
       ↓
Display Orders List
       ↓
[Optional] Filter by Status
```

---

## 📊 State Management

### Riverpod Providers

#### `authServiceProvider`
Provider untuk AuthService.

```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
```

---

#### `databaseServiceProvider`
Provider untuk DatabaseService.

```dart
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
```

---

#### `verificationIdProvider`
State provider untuk menyimpan verification ID sementara.

```dart
final verificationIdProvider = StateProvider<String>((ref) => '');
```

---

## 🧪 Testing Data

### Test Phone Numbers

Tambahkan di Firebase Console → Authentication → Sign-in method → Phone → Phone numbers for testing:

```
Phone: +62 812 3456 7890
Code: 123456

Phone: +62 811 1111 1111
Code: 111111
```

### Sample Menu Data

```json
{
  "menus": {
    "menu1": {
      "id": "menu1",
      "name": "Paket Nasi + Ayam Goreng",
      "description": "Nasi putih, ayam goreng krispi, sayur asem, kerupuk",
      "price": 15000,
      "imageUrl": "https://via.placeholder.com/300"
    }
  }
}
```

---

## 🚨 Error Handling

### Common Errors

#### `FirebaseAuthException: invalid-phone-number`
- **Cause:** Format nomor telepon salah
- **Solution:** Pastikan format `+62xxx` (tanpa spasi atau dash)

#### `FirebaseAuthException: invalid-verification-code`
- **Cause:** Kode OTP salah atau expired
- **Solution:** Request OTP baru

#### `DatabaseException: permission-denied`
- **Cause:** Database rules tidak mengizinkan akses
- **Solution:** Cek Firebase rules dan pastikan user sudah authenticated

---

## 📱 Platform-Specific Notes

### Android
- Minimal SDK: 21 (Android 5.0)
- Requires SHA-1 fingerprint untuk production
- Auto OTP verification didukung

### iOS
- Minimal iOS: 12.0
- Requires APNs certificate untuk production
- Silent push notification untuk auto verification

### Web
- Requires reCAPTCHA verification
- Test phone numbers tidak memerlukan reCAPTCHA

---

## 📚 Additional Resources

- [Firebase Auth API Reference](https://firebase.google.com/docs/reference/js/auth)
- [Realtime Database API Reference](https://firebase.google.com/docs/reference/js/database)
- [FlutterFire Documentation](https://firebase.flutter.dev)

---

**Last Updated:** 2026-08-24
