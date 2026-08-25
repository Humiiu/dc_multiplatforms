import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/database_service.dart';

final verificationIdProvider = StateProvider<String>((ref) => '');
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService(this.ref);

  // 1️⃣ Send OTP to phone number (for registration)
  Future<void> sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Verifikasi gagal: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        ref.read(verificationIdProvider.notifier).state = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ref.read(verificationIdProvider.notifier).state = verificationId;
      },
    );
  }

  // 2️⃣ Verify OTP code
  Future<User?> verifyOtp(String smsCode) async {
    final verificationId = ref.read(verificationIdProvider);
    if (verificationId.isEmpty) {
      throw Exception('Kode verifikasi kadaluarsa. Kirim ulang OTP.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // 3️⃣ Register user with full data (after OTP verification)
  Future<void> registerUser({
    required String uid,
    required String username,
    required String phone,
    required String name,
    required Jurusan jurusan,
    required Kelas kelas,
  }) async {
    final db = ref.read(databaseServiceProvider);
    await db.setUser(
      uid,
      AppUser(
        uid: uid,
        username: username,
        phone: phone,
        name: name,
        jurusan: jurusan,
        kelas: kelas,
        createdAt: DateTime.now(),
      ),
    );
  }

  // 4️⃣ Login with username/phone + password
  Future<User?> signInWithEmailAndPassword(String emailOrPhone, String password) async {
    String email = emailOrPhone;
    // If input looks like phone number, convert to email format
    // For now, we assume username is used as email or we store email separately
    if (emailOrPhone.startsWith('+62') || emailOrPhone.startsWith('08')) {
      // Phone number login - we'd need to look up the user by phone first
      // For simplicity, we'll use Firebase's email/password auth
      // In production, you'd query the database to find the email by phone
      throw Exception('Login dengan nomor telepon belum didukung. Gunakan username/email.');
    }
    // Assume it's an email or username
    if (!emailOrPhone.contains('@')) {
      // Treat as username - in production, look up email by username
      email = '$emailOrPhone@catering.app';
    }
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // 5️⃣ Create user with email/password (for initial registration if not using phone)
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // 6️⃣ Get current user stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // 7️⃣ Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 8️⃣ Update password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    await user.updatePassword(newPassword);
  }

  // 9️⃣ Re-authenticate for sensitive operations
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    final email = user.email ?? '';
    if (email.isEmpty) throw Exception('Email tidak tersedia');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }
}