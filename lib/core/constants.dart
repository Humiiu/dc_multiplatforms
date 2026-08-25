/// Konstanta global aplikasi Catering Booking.
class AppConstants {
  /// Batas maksimal utang per user (Rp 100.000).
  static const int maxUtang = 100000;

  /// Nomor WA admin untuk request menu khusus / tiket.
  /// TODO: ganti dengan nomor admin yang sebenarnya.
  static const String adminWhatsApp = '6281234567890';

  /// Harga default per hari catering (jika tidak ada di DB)
  static const int defaultDailyPrice = 20000;

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