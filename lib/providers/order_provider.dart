import '../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/order_validator.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../ui/demo_state.dart';
import 'user_provider.dart';

/// Stream saldo hutang (debts) pengguna dari Firebase Realtime Database
/// Mengembalikan 60.000 sebagai fallback saat mode demo/belum ada data di DB.
final userDebtStreamProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(60000);
  }
  return ref.watch(databaseServiceProvider).watchUserDebt(user.uid);
});

/// Stream riwayat order pengguna dari Firebase Realtime Database
final userOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(databaseServiceProvider).watchUserOrders(user.uid);
});

final orderServiceProvider = Provider<OrderService>((ref) => OrderService(ref));

class OrderService {
  final Ref ref;

  OrderService(this.ref);

  DatabaseService get _db => ref.read(databaseServiceProvider);
  AuthService get _auth => ref.read(authServiceProvider);

  /// Submit pesanan katering ke Firebase Realtime Database
  Future<String> submitCurrentOrder() async {
    final orderState = ref.read(demoOrderProvider);
    final userProfile = ref.read(currentUserProfileProvider).value;
    final authUser = _auth.currentUser;
    final uid = authUser?.uid ?? (userProfile?.uid ?? '');

    // 1. Tangani pelunasan hutang (Debt Payment)
    if (orderState.payingExistingDebt) {
      final amount = orderState.total;
      if (uid.isNotEmpty) {
        await _db.payDebt(uid, amount);
      }
      ref.read(demoOrderProvider.notifier).addDemoOrder();
      return 'debt_paid';
    }

    // 2. Validasi hari terpilih
    if (orderState.selectedDays.isEmpty) {
      throw Exception('Silakan pilih minimal 1 hari pesanan.');
    }

    final totalAmount = OrderValidator.calculateTotal(orderState.selectedDays.length);
    final isPayLater = orderState.paymentMethod == DemoPaymentMethod.payLater;

    // 3. Validasi limit hutang (Plafon Rp 100.000)
    if (isPayLater && uid.isNotEmpty) {
      final currentDebt = await _db.getUserDebt(uid);
      if (!OrderValidator.canUsePayLater(currentDebt: currentDebt, newOrderAmount: totalAmount)) {
        throw Exception(
          'Total hutang Anda akan menjadi Rp ${(currentDebt + totalAmount)}, '
          'melebihi batas plafon maksimal Pay Later (Rp 100.000). '
          'Silakan lunasi tagihan terlebih dahulu.',
        );
      }
    }

    // 4. Siapkan data hari dan waktu
    final now = DateTime.now();
    final dayNames = orderState.selectedDayDetails.map((d) => d.name).toList();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final fullMonthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final weekOfMonth = ((now.day - 1) ~/ 7) + 1;
    final weekLabel = '${fullMonthNames[now.month - 1]}, Minggu $weekOfMonth';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final hourStr = now.hour.toString().padLeft(2, '0');
    final dateLabel = '${now.day} ${monthNames[now.month - 1]} ${now.year} • $hourStr:$minuteStr WIB';

    final paymentName = switch (orderState.paymentMethod) {
      DemoPaymentMethod.qris => 'QRIS',
      DemoPaymentMethod.virtualAccount => 'Transfer BCA',
      DemoPaymentMethod.eWallet => 'E-Wallet',
      DemoPaymentMethod.payLater => 'Pay Later',
    };

    final order = Order(
      id: '',
      userId: uid,
      userName: userProfile?.name ?? 'Siswa',
      userPhone: userProfile?.phone ?? '',
      userClass: userProfile?.kelas.label ?? 'XII',
      userMajor: userProfile?.jurusan.label ?? 'RPL',
      week: weekLabel,
      date: dateLabel,
      days: dayNames,
      amount: totalAmount,
      payment: paymentName,
      isPaid: !isPayLater,
      status: isPayLater ? 'pending' : 'confirmed',
      createdAt: now,
      dueDate: isPayLater ? now.add(const Duration(days: 7)) : null,
      paidAt: !isPayLater ? now : null,
    );

    // 5. Simpan ke Firebase Realtime Database bila user terotentikasi
    String orderId = 'simulated';
    if (uid.isNotEmpty) {
      orderId = await _db.createOrder(order);
    }

    // 6. Update local state
    ref.read(demoOrderProvider.notifier).addDemoOrder();

    return orderId;
  }
}
