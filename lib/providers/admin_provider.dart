import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Cache sinkron role admin (dipakai oleh redirect di router).
/// Di-set saat `userDataProvider` selesai memuat AppUser.
class AdminRoleCache extends ChangeNotifier {
  bool _isAdmin = false;
  bool _loaded = false;

  bool get isAdmin => _isAdmin;
  bool get loaded => _loaded;

  void set(bool value) {
    if (_isAdmin == value && _loaded) return;
    _isAdmin = value;
    _loaded = true;
    notifyListeners();
  }

  void reset() {
    if (!_loaded && !_isAdmin) return;
    _isAdmin = false;
    _loaded = false;
    notifyListeners();
  }
}

final adminRoleCacheProvider = Provider<AdminRoleCache>((ref) {
  final cache = AdminRoleCache();

  // Saat userData berubah, sinkronkan cache.
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    cache.reset();
  } else {
    final user = ref.watch(userDataProvider(uid));
    user.when(
      data: (u) => cache.set(u?.role == UserRole.admin),
      loading: () {}, // Tunggu sampai termuat
      error: (e, _) => cache.set(false), // Gagal muat -> bukan admin
    );
  }

  // Juga reset cache saat logout secara eksplisit jika perlu,
  // tapi watch(currentUserIdProvider) sudah menangani itu.

  return cache;
});

/// Role user yang sedang login (user/admin). default `user` jika belum termuat.
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final user = ref.watch(userDataProvider(uid ?? ''));
  return user.valueOrNull?.role ?? UserRole.user;
});

/// Apakah user yang login bertindak sebagai admin (reaktif).
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider) == UserRole.admin;
});

/// Semua order antar user (khusus admin).
final adminOrdersProvider = FutureProvider<List<Order>>((ref) async {
  return ref.read(databaseServiceProvider).getAllOrders();
});

/// Semua user terdaftar (khusus admin).
final adminUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  return ref.read(databaseServiceProvider).getAllUsers();
});

/// Menu mingguan (dipakai juga di halaman admin).
final adminMenuProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(databaseServiceProvider).getWeeklyMenu();
});
