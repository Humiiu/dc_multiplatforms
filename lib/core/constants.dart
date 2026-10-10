/// Konstanta global aplikasi Catering Booking.
class AppConstants {
  /// Batas maksimal utang per user (Rp 100.000).
  static const int maxUtang = 100000;

  /// Nomor WA admin untuk request menu khusus / tiket.
  static const String adminWhatsApp = '628999107194';

  /// Placeholder WA admin untuk link frontend. Ganti saat API/backend siap.
  // ignore: constant_identifier_names
  static const String ADMIN_WA_NUMBER = '628999107194';

  /// Harga default per hari catering (jika tidak ada di DB)
  static const int defaultDailyPrice = 20000;

  /// Error messages
  static const String errPhoneEmpty = 'Nomor telepon tidak boleh kosong';
  static const String errPhoneInvalid = 'Format nomor telepon tidak valid';
  static const String errUsernameEmpty = 'Username tidak boleh kosong';
  static const String errUsernameTooShort = 'Username minimal 3 karakter';
  static const String errNameEmpty = 'Nama lengkap tidak boleh kosong';
  static const String errPasswordTooShort = 'Password minimal 6 karakter';
  static const String errPasswordNoMatch = 'Konfirmasi password tidak cocok';

  AppConstants._();
}

/// Hari kerja catering (Senin–Jumat).
const List<String> hariKerja = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

/// Hari kerja lowercase untuk database keys.
const List<String> hariKerjaDb = ['senin', 'selasa', 'rabu', 'kamis', 'jumat'];

/// Jurusan options untuk registrasi.
const List<String> jurusanOptions = ['RPL', 'DKV', 'ANM', 'BC', 'TKJ', 'GD'];

/// Kelas options untuk registrasi.
const List<String> kelasOptions = ['X', 'XI', 'XII'];