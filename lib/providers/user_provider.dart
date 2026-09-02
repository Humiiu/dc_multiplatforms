import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/database_service.dart';

/// Mengambil data AppUser dari Realtime DB berdasarkan uid.
/// null saat belum login / data belum ada di DB.
final userDataProvider = FutureProvider.family<AppUser?, String>((ref, uid) async {
  return ref.read(databaseServiceProvider).getUser(uid);
});
