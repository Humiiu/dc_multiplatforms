enum PaymentMethod { qris, virtualAccount, eWallet, hutang }

extension PaymentMethodExtension on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.qris => 'QRIS',
        PaymentMethod.virtualAccount => 'Virtual Account',
        PaymentMethod.eWallet => 'E-Wallet',
        PaymentMethod.hutang => 'Hutang',
      };

  String get subtitle => switch (this) {
        PaymentMethod.qris => 'Scan QRIS untuk bayar (1x pakai)',
        PaymentMethod.virtualAccount => 'Transfer ke nomor VA bank',
        PaymentMethod.eWallet => 'Bayar via e-Wallet (GoPay, OVO, dll)',
        PaymentMethod.hutang =>
            'Bayar nanti, jatuh tempo minggu ini (maks Rp 100.000)',
      };
}

/// Order model for catering bookings.
class Order {
  final String id;
  final String userId;
  final List<String> selectedDays; // e.g., ["senin", "selasa"]
  final Map<String, List<String>> menuPerDay; // day -> list of menu IDs
  final int totalPrice; // in Rupiah
  final bool isPaid;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? dueDate; // jatuh tempo (minggu yang sama)
  final DateTime? paidAt; // when payment was completed

  Order({
    required this.id,
    required this.userId,
    required this.selectedDays,
    required this.menuPerDay,
    required this.totalPrice,
    required this.isPaid,
    required this.paymentMethod,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
  });

  factory Order.fromMap(String id, Map<dynamic, dynamic> map) => Order(
        id: id,
        userId: map['userId'] as String,
        selectedDays: List<String>.from(map['selectedDays']),
        menuPerDay: (map['menuPerDay'] as Map).map(
          (k, v) => MapEntry(k as String, List<String>.from(v as List)),
        ),
        totalPrice: map['totalPrice'] as int,
        isPaid: map['isPaid'] as bool,
        paymentMethod: PaymentMethod.values.byName(
          map['paymentMethod'] as String? ?? 'hutang',
        ),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        dueDate: map['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
            : null,
        paidAt: map['paidAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['paidAt'] as int)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'selectedDays': selectedDays,
        'menuPerDay': menuPerDay.map(
          (k, v) => MapEntry(k, v),
        ),
        'totalPrice': totalPrice,
        'isPaid': isPaid,
        'paymentMethod': paymentMethod.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'paidAt': paidAt?.millisecondsSinceEpoch,
      };

  /// Get formatted week string (e.g., "Minggu 1 Oktober")
  String get weekLabel {
    final weekOfMonth = ((createdAt.day - 1) ~/ 7) + 1;
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return 'Minggu $weekOfMonth ${monthNames[createdAt.month - 1]}';
  }

  /// Check if order is hutang and overdue
  bool get isOverdue => !isPaid && dueDate != null && DateTime.now().isAfter(dueDate!);
}