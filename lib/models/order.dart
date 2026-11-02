enum PaymentMethod { qris, virtualAccount, eWallet, hutang }

extension PaymentMethodExtension on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.qris => 'QRIS',
        PaymentMethod.virtualAccount => 'Virtual Account',
        PaymentMethod.eWallet => 'E-Wallet',
        PaymentMethod.hutang => 'Pay Later',
      };

  String get subtitle => switch (this) {
        PaymentMethod.qris => 'Scan QRIS untuk bayar (1x pakai)',
        PaymentMethod.virtualAccount => 'Transfer ke nomor VA bank',
        PaymentMethod.eWallet => 'Bayar via e-Wallet (GoPay, OVO, dll)',
        PaymentMethod.hutang =>
            'Bayar nanti, jatuh tempo minggu ini (maks Rp 100.000)',
      };
}

/// Order model for Dian Catering sesuai dokumen DATA_MODEL.md
class Order {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userClass;
  final String userMajor;
  final String week; // e.g. "Oktober, Minggu 2"
  final String date; // e.g. "27 Okt 2026 • 11:06 WIB"
  final List<String> days; // ["Senin", "Selasa"]
  final int amount; // total bayar dlm Rupiah (flat Rp 20.000 / hari)
  final String payment; // 'QRIS', 'Pay Later', 'Virtual Account', 'E-Wallet'
  final bool isPaid;
  final String status; // 'pending', 'confirmed', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;

  Order({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    this.userClass = '',
    this.userMajor = '',
    this.week = '',
    this.date = '',
    required this.days,
    required this.amount,
    required this.payment,
    required this.isPaid,
    this.status = 'confirmed',
    required this.createdAt,
    this.dueDate,
    this.paidAt,
  });

  // Backward compatibility getters
  List<String> get selectedDays => days.map((d) => d.toLowerCase()).toList();
  int get totalPrice => amount;
  PaymentMethod get paymentMethod {
    if (payment.toLowerCase().contains('later') || payment.toLowerCase().contains('hutang')) {
      return PaymentMethod.hutang;
    }
    if (payment.toLowerCase().contains('virtual')) {
      return PaymentMethod.virtualAccount;
    }
    if (payment.toLowerCase().contains('wallet')) {
      return PaymentMethod.eWallet;
    }
    return PaymentMethod.qris;
  }

  factory Order.fromMap(String id, Map<dynamic, dynamic> map) {
    // Menangani field 'days' atau 'selectedDays'
    List<String> parsedDays = [];
    if (map['days'] is List) {
      parsedDays = List<String>.from(map['days']);
    } else if (map['selectedDays'] is List) {
      parsedDays = List<String>.from(map['selectedDays']).map((d) => _capitalize(d)).toList();
    }

    final createdAtMs = (map['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMs);

    final amount = ((map['amount'] ?? map['totalPrice'] ?? (parsedDays.length * 20000)) as num).toInt();
    final payment = (map['payment'] ?? map['paymentMethod'] ?? 'QRIS') as String;
    final isPaid = (map['isPaid'] as bool?) ?? false;
    final status = (map['status'] as String?) ?? (isPaid ? 'confirmed' : 'pending');

    return Order(
      id: id,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      userPhone: (map['userPhone'] ?? '') as String,
      userClass: (map['userClass'] ?? '') as String,
      userMajor: (map['userMajor'] ?? '') as String,
      week: (map['week'] ?? '') as String,
      date: (map['date'] ?? '') as String,
      days: parsedDays,
      amount: amount,
      payment: payment,
      isPaid: isPaid,
      status: status,
      createdAt: createdAt,
      dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch((map['dueDate'] as num).toInt()) : null,
      paidAt: map['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch((map['paidAt'] as num).toInt()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'userClass': userClass,
        'userMajor': userMajor,
        'week': week,
        'date': date,
        'days': days,
        'amount': amount,
        'payment': payment,
        'isPaid': isPaid,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
        if (dueDate != null) 'dueDate': dueDate!.millisecondsSinceEpoch,
        if (paidAt != null) 'paidAt': paidAt!.millisecondsSinceEpoch,
      };

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  /// Format label minggu pesanan
  String get weekLabel {
    if (week.isNotEmpty) return week;
    final weekOfMonth = ((createdAt.day - 1) ~/ 7) + 1;
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return 'Minggu $weekOfMonth ${monthNames[createdAt.month - 1]}';
  }

  /// Cek apakah pesanan hutang telah jatuh tempo
  bool get isOverdue => !isPaid && dueDate != null && DateTime.now().isAfter(dueDate!);
}
