import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides the currently signed-in Firebase user (or null if not signed in).
final currentUserProvider = Provider<User?>((ref) => FirebaseAuth.instance.currentUser);

/// Provider for the current user's UID
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});