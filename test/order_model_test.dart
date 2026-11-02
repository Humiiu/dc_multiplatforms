import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/models/order.dart';

void main() {
  group('Order Model Serialization & Business Logic', () {
    test('fromMap parses modern and legacy fields with safe fallbacks', () {
      final now = DateTime.now();
      final map = {
        'userId': 'uid_123',
        'userName': 'Humiiu',
        'userClass': 'XII RPL 1',
        'week': 'Oktober, Minggu 2',
        'date': '27 Okt 2026 • 11:06 WIB',
        'days': ['Senin', 'Selasa'],
        'amount': 40000,
        'payment': 'QRIS',
        'isPaid': true,
        'status': 'confirmed',
        'createdAt': now.millisecondsSinceEpoch,
      };

      final order = Order.fromMap('order_abc', map);

      expect(order.id, 'order_abc');
      expect(order.userId, 'uid_123');
      expect(order.userName, 'Humiiu');
      expect(order.userClass, 'XII RPL 1');
      expect(order.week, 'Oktober, Minggu 2');
      expect(order.days, ['Senin', 'Selasa']);
      expect(order.amount, 40000);
      expect(order.totalPrice, 40000);
      expect(order.payment, 'QRIS');
      expect(order.isPaid, isTrue);
      expect(order.status, 'confirmed');
    });

    test('fromMap handles fallback legacy fields (selectedDays, totalPrice)', () {
      final map = {
        'userId': 'uid_456',
        'selectedDays': ['senin', 'rabu', 'jumat'],
        'totalPrice': 60000,
        'paymentMethod': 'Transfer BCA',
        'isPaid': false,
        'createdAt': 1698000000000,
      };

      final order = Order.fromMap('order_def', map);

      expect(order.id, 'order_def');
      expect(order.days, ['Senin', 'Rabu', 'Jumat']);
      expect(order.amount, 60000);
      expect(order.payment, 'Transfer BCA');
      expect(order.isPaid, isFalse);
      expect(order.status, 'pending');
    });

    test('toMap serializes all fields into valid RTDB json map', () {
      final createdAt = DateTime(2026, 11, 2, 10, 0);
      final dueDate = DateTime(2026, 11, 9, 23, 59);
      final paidAt = DateTime(2026, 11, 2, 10, 15);

      final order = Order(
        id: 'order_test_1',
        userId: 'uid_test',
        userName: 'Siswa Test',
        userPhone: '081234567890',
        userClass: 'XII',
        userMajor: 'RPL',
        week: 'November, Minggu 1',
        date: '2 Nov 2026 • 10:00 WIB',
        days: ['Senin', 'Selasa'],
        amount: 40000,
        payment: 'Pay Later',
        isPaid: true,
        status: 'completed',
        createdAt: createdAt,
        dueDate: dueDate,
        paidAt: paidAt,
      );

      final map = order.toMap();

      expect(map['id'], 'order_test_1');
      expect(map['userId'], 'uid_test');
      expect(map['userName'], 'Siswa Test');
      expect(map['userPhone'], '081234567890');
      expect(map['amount'], 40000);
      expect(map['payment'], 'Pay Later');
      expect(map['isPaid'], isTrue);
      expect(map['status'], 'completed');
      expect(map['createdAt'], createdAt.millisecondsSinceEpoch);
      expect(map['dueDate'], dueDate.millisecondsSinceEpoch);
      expect(map['paidAt'], paidAt.millisecondsSinceEpoch);
    });

    test('paymentMethod getter maps Pay Later and other payment methods correctly', () {
      final orderPayLater = Order(
        id: '1',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'Pay Later',
        isPaid: false,
        createdAt: DateTime.now(),
      );
      expect(orderPayLater.paymentMethod, PaymentMethod.hutang);

      final orderVA = Order(
        id: '2',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'Virtual Account',
        isPaid: true,
        createdAt: DateTime.now(),
      );
      expect(orderVA.paymentMethod, PaymentMethod.virtualAccount);

      final orderWallet = Order(
        id: '3',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'E-Wallet (Dana)',
        isPaid: true,
        createdAt: DateTime.now(),
      );
      expect(orderWallet.paymentMethod, PaymentMethod.eWallet);

      final orderQRIS = Order(
        id: '4',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'QRIS',
        isPaid: true,
        createdAt: DateTime.now(),
      );
      expect(orderQRIS.paymentMethod, PaymentMethod.qris);
    });

    test('isOverdue detects past dueDate on unpaid orders', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final futureDate = DateTime.now().add(const Duration(days: 5));

      final overdueOrder = Order(
        id: 'overdue_1',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'Pay Later',
        isPaid: false,
        createdAt: pastDate.subtract(const Duration(days: 7)),
        dueDate: pastDate,
      );
      expect(overdueOrder.isOverdue, isTrue);

      final paidOverdueOrder = Order(
        id: 'overdue_2',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'Pay Later',
        isPaid: true, // already paid
        createdAt: pastDate.subtract(const Duration(days: 7)),
        dueDate: pastDate,
      );
      expect(paidOverdueOrder.isOverdue, isFalse);

      final currentOrder = Order(
        id: 'active_1',
        userId: 'u1',
        days: ['Senin'],
        amount: 20000,
        payment: 'Pay Later',
        isPaid: false,
        createdAt: DateTime.now(),
        dueDate: futureDate,
      );
      expect(currentOrder.isOverdue, isFalse);
    });
  });
}
