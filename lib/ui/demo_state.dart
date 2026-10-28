import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Riverpod provider exposing the [DemoOrderNotifier].
/// We use the modern NotifierProvider (Riverpod 3.x) instead of the older
/// ChangeNotifierProvider. The state is immutable: every mutation replaces it
/// with a new [DemoOrderState] instance so listeners are notified.
final demoOrderProvider =
    NotifierProvider<DemoOrderNotifier, DemoOrderState>(DemoOrderNotifier.new);

/// A Riverpod Notifier wrapping the [DemoOrderState] model.
/// Each public method produces a *new* state instance via [DemoOrderState.copyWith].
/// Reusing the same instance would not notify listeners because Riverpod's
/// default `updateShouldNotify` compares states with `!=`.
class DemoOrderNotifier extends Notifier<DemoOrderState> {
  @override
  DemoOrderState build() => DemoOrderState();

  void toggleDay(String key) {
    final selected = Set<String>.from(state.selectedDays);
    if (!selected.add(key)) {
      selected.remove(key);
    }
    state = state.copyWith(selectedDays: selected);
  }

  void selectPayment(DemoPaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void prepareDebtPayment(int amount, {String? targetWeek}) {
    state = state.copyWith(
      debtPaymentTotal: amount,
      debtTargetWeek: targetWeek,
      // A debt without an explicit target must not keep a stale week.
      clearDebtTarget: targetWeek == null,
    );
  }

  void addDemoOrder() {
    if (state.payingExistingDebt) {
      final targetWeek = state.debtTargetWeek;
      final orders = List<DemoHistoryOrder>.from(state.orders);
      if (targetWeek != null) {
        final index = orders.indexWhere((order) => order.week == targetWeek);
        if (index >= 0) {
          final order = orders[index];
          orders[index] = DemoHistoryOrder(
            week: order.week,
            date: order.date,
            days: order.days,
            payment: 'Simulasi Pembayaran',
            amount: order.amount,
            isPaid: true,
          );
        }
      }
      state = state.copyWith(orders: orders, clearDebt: true, clearDebtTarget: true);
      return;
    }

    if (state.selectedDays.isEmpty) return;
    final daysNames = state.selectedDayDetails.map((day) => day.name).toList();

    final orders = List<DemoHistoryOrder>.from(state.orders);
    orders.insert(
      0,
      DemoHistoryOrder(
        week: 'Pesanan terbaru',
        date: 'Baru saja • Simulasi',
        days: daysNames,
        payment: state.paymentMethod == DemoPaymentMethod.payLater
            ? 'Menunggu Pembayaran'
            : 'Pembayaran Diterima',
        amount: state.total,
        isPaid: state.paymentMethod != DemoPaymentMethod.payLater,
      ),
    );
    state = state.copyWith(orders: orders);
  }
}

const demoDays = [
  DemoDay(
    key: 'senin',
    name: 'Senin',
    menu: 'Nasi Liwet, Ayam Goreng, Tempe-Goreng, Sambal',
  ),
  DemoDay(
    key: 'selasa',
    name: 'Selasa',
    menu: 'Ayam Telur Asin, Martabak tahu, Kacang panjang banawag',
  ),
  DemoDay(
    key: 'rabu',
    name: 'Rabu',
    menu: 'Ayam HotLava, Tahu Krispi, Timun',
  ),
  DemoDay(
    key: 'kamis',
    name: 'Kamis',
    menu: 'Ayam Teriyaki, Nasi, Sayuran, Wijen',
  ),
  DemoDay(
    key: 'jumat',
    name: 'Jumat',
    menu: 'Nasi Goreng Spesial, Telur, Ayam Suwir, Kerupuk',
  ),
];

class DemoDay {
  final String key;
  final String name;
  final String menu;

  const DemoDay({
    required this.key,
    required this.name,
    required this.menu,
  });
}

enum DemoPaymentMethod { qris, virtualAccount, eWallet, payLater }

class DemoHistoryOrder {
  final String week;
  final String date;
  final List<String> days;
  final String payment;
  final int amount;
  final bool isPaid;

  const DemoHistoryOrder({
    required this.week,
    required this.date,
    required this.days,
    required this.payment,
    required this.amount,
    required this.isPaid,
  });
}

class DemoOrderState {
  // TODO(backend): replace mock order state with Firebase Realtime Database records.
  final Set<String> _selectedDays;
  final DemoPaymentMethod _paymentMethod;
  final int? _debtPaymentTotal;
  final String? _debtTargetWeek;
  final List<DemoHistoryOrder> _orders;

  DemoOrderState({
    Set<String>? selectedDays,
    DemoPaymentMethod? paymentMethod,
    int? debtPaymentTotal,
    String? debtTargetWeek,
    List<DemoHistoryOrder>? orders,
  })  : _selectedDays = Set<String>.from(selectedDays ?? {'senin', 'selasa'}),
        _paymentMethod = paymentMethod ?? DemoPaymentMethod.payLater,
        _debtPaymentTotal = debtPaymentTotal,
        _debtTargetWeek = debtTargetWeek,
        _orders = List<DemoHistoryOrder>.from(orders ?? const [
          DemoHistoryOrder(
            week: 'Oktober, Minggu 1',
            date: '27 Okt 2009 • 11:06 WIB',
            days: ['Ketring (5 hari)'],
            payment: 'Transfer BCA',
            amount: 250000,
            isPaid: true,
          ),
          DemoHistoryOrder(
            week: 'Oktober, Minggu 2',
            date: '27 Okt 2009 • 11:06 WIB',
            days: ['Ketring (5 hari)'],
            payment: 'Menunggu Pembayaran',
            amount: 450000,
            isPaid: false,
          ),
          DemoHistoryOrder(
            week: 'Oktober, Minggu 3',
            date: '27 Okt 2009 • 11:06 WIB',
            days: ['Ketring (5 hari)'],
            payment: 'Transfer Mandiri',
            amount: 500000,
            isPaid: true,
          ),
        ]);

  Set<String> get selectedDays => Set.unmodifiable(_selectedDays);
  DemoPaymentMethod get paymentMethod => _paymentMethod;
  String? get debtTargetWeek => _debtTargetWeek;
  List<DemoHistoryOrder> get orders => List.unmodifiable(_orders);

  int get total => _debtPaymentTotal ?? _selectedDays.length * 20000;
  bool get payingExistingDebt => _debtPaymentTotal != null;

  List<DemoDay> get selectedDayDetails =>
      demoDays.where((day) => _selectedDays.contains(day.key)).toList();

  DemoOrderState copyWith({
    Set<String>? selectedDays,
    DemoPaymentMethod? paymentMethod,
    int? debtPaymentTotal,
    bool clearDebt = false,
    String? debtTargetWeek,
    bool clearDebtTarget = false,
    List<DemoHistoryOrder>? orders,
  }) {
    return DemoOrderState(
      selectedDays: selectedDays ?? _selectedDays,
      paymentMethod: paymentMethod ?? _paymentMethod,
      debtPaymentTotal: clearDebt ? null : (debtPaymentTotal ?? _debtPaymentTotal),
      debtTargetWeek: clearDebtTarget ? null : (debtTargetWeek ?? _debtTargetWeek),
      orders: orders ?? _orders,
    );
  }
}
