import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides the currently signed-in Firebase user (or null if not signed in).
final currentUserProvider = Provider<User?>((ref) => FirebaseAuth.instance.currentUser);

/// Stream provider for auth state changes (real-time)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for the current user's UID
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Verification ID for OTP flow
final verificationIdProvider = StateProvider<String>((ref) => '');

/// OTP status: idle, sending, sent, error
enum OtpStatus { idle, sending, sent, error }

/// OTP status provider
final otpStatusProvider = StateProvider<OtpStatus>((ref) => OtpStatus.idle);

/// OTP error message provider
final otpErrorProvider = StateProvider<String?>((ref) => null);

/// Registration form state
final registrationFormProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'username': '',
  'phone': '',
  'name': '',
  'jurusan': 'RPL',
  'kelas': 'X',
  'password': '',
});