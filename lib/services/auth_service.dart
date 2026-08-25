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
  Future<User?> signInWithEmailAndPassword(String usernameOrPhone, String password) async {
    final db = ref.read(databaseServiceProvider);
    AppUser? appUser;

    // Determine if input is phone number or username
    final isPhone = usernameOrPhone.startsWith('+62') ||
        usernameOrPhone.startsWith('08') ||
        usernameOrPhone.startsWith('62');

    if (isPhone) {
      // Normalize phone and look up by phone
      // For login, accept raw input and try to normalize
      var digits = usernameOrPhone.replaceAll(RegExp(r'[\s\-().]'), '');
      if (digits.startsWith('+62')) {
        digits = digits.substring(3);
      } else if (digits.startsWith('62')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0')) {
        digits = digits.substring(1);
      }
      if (digits.startsWith('8') && digits.length >= 9) {
        appUser = await db.getUserByPhone('+62$digits');
      }
    } else {
      // Look up by username
      appUser = await db.getUserByUsername(usernameOrPhone.trim());
    }

    if (appUser == null) {
      throw Exception('Akun tidak ditemukan. Silakan daftar terlebih dahulu.');
    }

    // Use UID-based email format for Firebase auth
    final email = '${appUser.uid}@catering.app';
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