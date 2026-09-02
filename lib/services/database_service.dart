import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/order.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  // ---------- USER ----------
  Future<void> setUser(String uid, AppUser user) async {
    try {
      // Write user data + lookup indexes in one batch
      final updates = <String, dynamic>{
        'users/$uid': user.toMap(),
        'usernames/${user.username}': {'uid': uid},
        'phones/${user.phone}': {'uid': uid},
      };
      await _root.update(updates);
    } catch (e) {
      debugPrint('[DatabaseService] setUser error: $e');
      rethrow;
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final snap = await _root.child('users').child(uid).get();
      if (!snap.exists) return null;
      return AppUser.fromMap(uid, snap.value as Map);
    } catch (e) {
      debugPrint('[DatabaseService] getUser error: $e');
      return null;
    }
  }

  /// Update specific user fields (e.g., photoUrl, name)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _root.child('users').child(uid).update(data);
    } catch (e) {
      debugPrint('[DatabaseService] updateUser error: $e');
      rethrow;
    }
  }

  /// Check if username is already taken (via lookup index)
  Future<bool> isUsernameTaken(String username) async {
    try {
      final snap = await _root.child('usernames').child(username).get();
      return snap.exists;
    } catch (e) {
      debugPrint('[DatabaseService] isUsernameTaken error: $e');
      return false;
    }
  }

  /// Check if phone is already registered (via lookup index)
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final snap = await _root.child('phones').child(phone).get();
      return snap.exists;
    } catch (e) {
      debugPrint('[DatabaseService] isPhoneRegistered error: $e');
      return false;
    }
  }

  /// Look up user by username via /usernames lookup index
  Future<AppUser?> getUserByUsername(String username) async {
    try {
      final snap = await _root.child('usernames').child(username).get();
      if (!snap.exists || snap.value == null) return null;
      final data = snap.value as Map;
      final uid = data['uid'] as String?;
      if (uid == null || uid.isEmpty) return null;
      return getUser(uid);
    } catch (e) {
      debugPrint('[DatabaseService] getUserByUsername error: $e');
      return null;
    }
  }

  /// Get UID by phone from /phones lookup (no auth needed)
  Future<String?> getUidByPhone(String phone) async {
    try {
      final snap = await _root.child('phones').child(phone).get();
      if (!snap.exists || snap.value == null) return null;
      final data = snap.value as Map;
      final uid = data['uid'] as String?;
      if (uid == null || uid.isEmpty) return null;
      return uid;
    } catch (e) {
      debugPrint('[DatabaseService] getUidByPhone error: $e');
      return null;
    }
  }

  /// Look up user by phone number via /phones lookup index
  Future<AppUser?> getUserByPhone(String phone) async {
    try {
      final uid = await getUidByPhone(phone);
      if (uid == null) return null;
      return getUser(uid);
    } catch (e) {
      debugPrint('[DatabaseService] getUserByPhone error: $e');
      return null;
    }
  }

  // ---------- MENU ----------
  // Structure: /menus/{day}/{menuId} where day is lowercase (senin, selasa, etc.)
  Future<Map<String, dynamic>> getWeeklyMenu() async {
    try {
      final snap = await _root.child('menus').get();
      if (!snap.exists) return {};
      return (snap.value as Map).cast<String, dynamic>();
    } catch (e) {
      debugPrint('[DatabaseService] getWeeklyMenu error: $e');
      return {};
    }
  }

  /// Get menu for a specific day (key lowercase, e.g., 'senin')
  Future<Map<String, dynamic>> getMenusForDay(String day) async {
    try {
      final snap = await _root.child('menus').child(day.toLowerCase()).get();
      if (!snap.exists) return {};
      return (snap.value as Map).cast<String, dynamic>();
    } catch (e) {
      debugPrint('[DatabaseService] getMenusForDay error: $e');
      return {};
    }
  }

  /// Add/update a menu item for a day
  Future<void> setMenuForDay(String day, String menuId, Map<String, dynamic> data) async {
    try {
      await _root.child('menus').child(day.toLowerCase()).child(menuId).set(data);
    } catch (e) {
      debugPrint('[DatabaseService] setMenuForDay error: $e');
      rethrow;
    }
  }

  // ---------- ORDER ----------
  Future<void> createOrder(Order order) async {
    try {
      final newRef = _root.child('orders').push();
      await newRef.set(order.toMap());
    } catch (e) {
      debugPrint('[DatabaseService] createOrder error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getUserOrders(String uid) async {
    try {
      final snap = await _root
          .child('orders')
          .orderByChild('userId')
          .equalTo(uid)
          .get();
      if (!snap.exists) return [];
      final Map<String, dynamic> map = (snap.value as Map).cast<String, dynamic>();
      return map.entries
          .map((e) => Order.fromMap(e.key, e.value as Map))
          .toList();
    } catch (e) {
      // Graceful fallback — show empty state instead of crash
      debugPrint('[DatabaseService] getUserOrders error: $e');
      return [];
    }
  }

  /// Get all active (unpaid) orders for a specific user - used for Tagihan Kamu
  Future<List<Order>> getActiveOrders(String uid) async {
    try {
      final snap = await _root
          .child('orders')
          .orderByChild('userId')
          .equalTo(uid)
          .get();
      if (!snap.exists) return [];
      final map = (snap.value as Map).cast<String, dynamic>();
      return map.entries
          .map((e) => Order.fromMap(e.key, e.value as Map))
          .where((o) => !o.isPaid)
          .toList();
    } catch (e) {
      debugPrint('[DatabaseService] getActiveOrders error: $e');
      return [];
    }
  }

  /// Mark order as paid (with error handling)
  Future<void> markPaid(String orderId) async {
    try {
      await _root.child('orders').child(orderId).child('isPaid').set(true);
      await _root
          .child('orders')
          .child(orderId)
          .child('paidAt')
          .set(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[DatabaseService] markPaid error: $e');
      rethrow;
    }
  }

  // ---------- ADMIN ----------

  /// Get ALL orders across every user (admin only).
  Future<List<Order>> getAllOrders() async {
    try {
      final snap = await _root.child('orders').get();
      if (!snap.exists) return [];
      final map = (snap.value as Map).cast<String, dynamic>();
      return map.entries
          .map((e) => Order.fromMap(e.key, e.value as Map))
          .toList();
    } catch (e) {
      debugPrint('[DatabaseService] getAllOrders error: $e');
      return [];
    }
  }

  /// Get ALL registered users (admin only).
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snap = await _root.child('users').get();
      if (!snap.exists) return [];
      final map = (snap.value as Map).cast<String, dynamic>();
      return map.entries
          .map((e) => AppUser.fromMap(e.key, e.value as Map))
          .toList();
    } catch (e) {
      debugPrint('[DatabaseService] getAllUsers error: $e');
      return [];
    }
  }

  /// Set paid-status of an order (admin fulfillment). Preserves userId ownership check server-side via rules.
  Future<void> updateOrderPaidStatus(String orderId, bool isPaid) async {
    try {
      final updates = <String, dynamic>{
        'isPaid': isPaid,
        if (isPaid) 'paidAt': DateTime.now().millisecondsSinceEpoch,
        if (!isPaid) 'paidAt': null,
      };
      await _root.child('orders').child(orderId).update(updates);
    } catch (e) {
      debugPrint('[DatabaseService] updateOrderPaidStatus error: $e');
      rethrow;
    }
  }

  /// Delete a menu item for a day.
  Future<void> deleteMenuItem(String day, String menuId) async {
    try {
      await _root.child('menus').child(day.toLowerCase()).child(menuId).remove();
    } catch (e) {
      debugPrint('[DatabaseService] deleteMenuItem error: $e');
      rethrow;
    }
  }
}