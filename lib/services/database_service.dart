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
    await _root.child('users').child(uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _root.child('users').child(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(uid, snap.value as Map);
  }

  /// Update specific user fields (e.g., photoUrl, name)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _root.child('users').child(uid).update(data);
  }

  /// Check if username is already taken
  Future<bool> isUsernameTaken(String username) async {
    final snap = await _root
        .child('users')
        .orderByChild('username')
        .equalTo(username)
        .get();
    return snap.exists;
  }

  /// Check if phone is already registered
  Future<bool> isPhoneRegistered(String phone) async {
    final snap = await _root
        .child('users')
        .orderByChild('phone')
        .equalTo(phone)
        .get();
    return snap.exists;
  }

  /// Look up user by username
  Future<AppUser?> getUserByUsername(String username) async {
    final snap = await _root
        .child('users')
        .orderByChild('username')
        .equalTo(username)
        .get();
    if (!snap.exists || snap.value == null) return null;
    final map = snap.value as Map;
    if (map.isEmpty) return null;
    final entry = map.entries.first;
    return AppUser.fromMap(entry.key as String, entry.value as Map);
  }

  /// Look up user by phone number (normalized +62 format)
  Future<AppUser?> getUserByPhone(String phone) async {
    final snap = await _root
        .child('users')
        .orderByChild('phone')
        .equalTo(phone)
        .get();
    if (!snap.exists || snap.value == null) return null;
    final map = snap.value as Map;
    if (map.isEmpty) return null;
    final entry = map.entries.first;
    return AppUser.fromMap(entry.key as String, entry.value as Map);
  }

  // ---------- MENU ----------
  // Structure: /menus/{day}/{menuId} where day is lowercase (senin, selasa, etc.)
  Future<Map<String, dynamic>> getWeeklyMenu() async {
    final snap = await _root.child('menus').get();
    if (!snap.exists) return {};
    return (snap.value as Map).cast<String, dynamic>();
  }

  /// Get menu for a specific day (key lowercase, e.g., 'senin')
  Future<Map<String, dynamic>> getMenusForDay(String day) async {
    final snap = await _root.child('menus').child(day.toLowerCase()).get();
    if (!snap.exists) return {};
    return (snap.value as Map).cast<String, dynamic>();
  }

  /// Add/update a menu item for a day
  Future<void> setMenuForDay(String day, String menuId, Map<String, dynamic> data) async {
    await _root.child('menus').child(day.toLowerCase()).child(menuId).set(data);
  }

  // ---------- ORDER ----------
  Future<void> createOrder(Order order) async {
    final newRef = _root.child('orders').push();
    await newRef.set(order.toMap());
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

  /// Get all active (unpaid) orders - used for Tagihan Kamu
  Future<List<Order>> getActiveOrders() async {
    try {
      final snap = await _root.child('orders').get();
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

  /// Mark order as paid
  Future<void> markPaid(String orderId) async {
    await _root.child('orders').child(orderId).child('isPaid').set(true);
  }
}