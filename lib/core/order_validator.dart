/// Validator aturan bisnis pemesanan Dian Catering sesuai PROJECT_SPEC.md
class OrderValidator {
  /// Harga flat per box katering
  static const int pricePerDay = 20000;

  /// Plafon maksimal hutang (Pay Later)
  static const int maxDebtLimit = 100000;

  /// Jam cut-off pemesanan malam hari: 21:30 WIB
  static const int cutoffHour = 21;
  static const int cutoffMinute = 30;

  /// Menghitung total harga berdasarkan jumlah hari terpilih
  static int calculateTotal(int daysCount) {
    return daysCount * pricePerDay;
  }

  /// Validasi apakah siswa dapat menggunakan opsi Pay Later (ngutang)
  /// Maksimal akumulasi hutang adalah Rp 100.000
  static bool canUsePayLater({
    required int currentDebt,
    required int newOrderAmount,
  }) {
    return (currentDebt + newOrderAmount) <= maxDebtLimit;
  }

  /// Validasi batas cut-off pemesanan harian (maks 21:30 WIB).
  /// Mengembalikan true bila masih sebelum atau tepat pukul 21:30 WIB.
  static bool isWithinCutoff([DateTime? time]) {
    final now = time ?? DateTime.now();
    final cutoffTotalMinutes = cutoffHour * 60 + cutoffMinute;
    final currentTotalMinutes = now.hour * 60 + now.minute;
    return currentTotalMinutes <= cutoffTotalMinutes;
  }
}
