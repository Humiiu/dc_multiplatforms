import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

/// Provider tagihan aktif user (utang yang belum dibayar).
final tagihanProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return 0;
  final orders = await db.getActiveOrders(uid);
  return orders.fold(0, (sum, o) => o.totalPrice);
});

/// Provider untuk daftar pesanan user.
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  return db.getUserOrders(uid);
});
