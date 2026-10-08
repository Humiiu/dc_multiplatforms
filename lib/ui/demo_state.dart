import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final demoOrderProvider =
    ChangeNotifierProvider<DemoOrderState>((ref) => DemoOrderState());

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

class DemoOrderState extends ChangeNotifier {
  final Set<String> _selectedDays = {'senin', 'selasa'};
  DemoPaymentMethod _paymentMethod = DemoPaymentMethod.payLater;
  int? _debtPaymentTotal;
  String? _debtTargetWeek;
  final List<DemoHistoryOrder> _orders = [
    const DemoHistoryOrder(
      week: 'Oktober, Minggu 1',
      date: '27 Okt 2009 • 11:06 WIB',
      days: ['Ketring (5 hari)'],
      payment: 'Transfer BCA',
      amount: 250000,
      isPaid: true,
    ),
    const DemoHistoryOrder(
      week: 'Oktober, Minggu 2',
      date: '27 Okt 2009 • 11:06 WIB',
      days: ['Ketring (5 hari)'],
      payment: 'Menunggu Pembayaran',
      amount: 450000,
      isPaid: false,
    ),
    const DemoHistoryOrder(
      week: 'Oktober, Minggu 3',
      date: '27 Okt 2009 • 11:06 WIB',
      days: ['Ketring (5 hari)'],
      payment: 'Transfer Mandiri',
      amount: 500000,
      isPaid: true,
    ),
  ];

  Set<String> get selectedDays => Set.unmodifiable(_selectedDays);
  DemoPaymentMethod get paymentMethod => _paymentMethod;
  List<DemoHistoryOrder> get orders => List.unmodifiable(_orders);

  int get total => _debtPaymentTotal ?? _selectedDays.length * 20000;
  bool get payingExistingDebt => _debtPaymentTotal != null;

  List<DemoDay> get selectedDayDetails =>
      demoDays.where((day) => _selectedDays.contains(day.key)).toList();

  void toggleDay(String key) {
    if (!_selectedDays.add(key)) _selectedDays.remove(key);
    notifyListeners();
  }

  void selectPayment(DemoPaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void prepareDebtPayment(int amount, {String? targetWeek}) {
    _debtPaymentTotal = amount;
    _debtTargetWeek = targetWeek;
    notifyListeners();
  }

  void addDemoOrder() {
    if (_debtPaymentTotal != null) {
      final index = _debtTargetWeek == null
          ? -1
          : _orders.indexWhere((order) => order.week == _debtTargetWeek);
      if (index >= 0) {
        final order = _orders[index];
        _orders[index] = DemoHistoryOrder(
          week: order.week,
          date: order.date,
          days: order.days,
          payment: 'Simulasi Pembayaran',
          amount: order.amount,
          isPaid: true,
        );
      }
      _debtPaymentTotal = null;
      _debtTargetWeek = null;
      notifyListeners();
      return;
    }
    if (_selectedDays.isEmpty) return;
    final days = selectedDayDetails.map((day) => day.name).toList();
    _orders.insert(
      0,
      DemoHistoryOrder(
        week: 'Pesanan terbaru',
        date: 'Baru saja • Simulasi',
        days: days,
        payment: 'Menunggu Pembayaran',
        amount: total,
        isPaid: false,
      ),
    );
    notifyListeners();
  }
}
