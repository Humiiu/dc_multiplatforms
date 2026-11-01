import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/database_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) {
    return const Stream.empty();
  }
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref ref;

  AuthService(this.ref);

  FirebaseAuth get _auth => FirebaseAuth.instance;
  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  /// Helper untuk masking username ke format email virtual Firebase Auth
  static String maskUsernameToEmail(String username) {
    final clean = username.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_.]'), '');
    return '$clean@diancatering.app';
  }

  /// Registrasi user baru (siswa)
  Future<User?> register({
    required String name,
    required String username,
    required String phone,
    required Kelas kelas,
    required Jurusan jurusan,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPhone = phone.trim();

    if (!isFirebaseAvailable) {
      debugPrint('[AuthService] Firebase offline/test mode: register mocked');
      return null;
    }

    final db = ref.read(databaseServiceProvider);

    // 1. Cek ketersediaan username di Realtime Database
    final usernameExists = await db.isUsernameTaken(cleanUsername);
    if (usernameExists) {
      throw Exception('Username "$cleanUsername" sudah digunakan. Silakan pilih username lain.');
    }

    // 2. Cek apakah nomor telepon sudah terdaftar
    final phoneExists = await db.isPhoneRegistered(cleanPhone);
    if (phoneExists) {
      throw Exception('Nomor telepon "$cleanPhone" sudah terdaftar.');
    }

    // 3. Buat akun Firebase Auth dengan email masking virtual
    final email = maskUsernameToEmail(cleanUsername);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Gagal membuat akun.');
    }

    // 4. Simpan data profil AppUser ke Realtime Database
    final appUser = AppUser(
      uid: user.uid,
      username: cleanUsername,
      name: name.trim(),
      phone: cleanPhone,
      kelas: kelas,
      jurusan: jurusan,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );
    await db.setUser(user.uid, appUser);

    return user;
  }

  /// Login dengan username dan password
  Future<User?> signIn({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();

    if (!isFirebaseAvailable) {
      debugPrint('[AuthService] Firebase offline/test mode: signIn mocked');
      return null;
    }

    final email = maskUsernameToEmail(cleanUsername);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Username "$cleanUsername" tidak ditemukan.');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Password yang Anda masukkan salah.');
        case 'network-request-failed':
          throw Exception('Gagal terhubung ke jaringan. Periksa koneksi internet Anda.');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan gagal. Silakan coba beberapa saat lagi.');
        default:
          throw Exception(e.message ?? 'Gagal login. Silakan coba lagi.');
      }
    }
  }

  Stream<User?> authStateChanges() {
    if (!isFirebaseAvailable) return const Stream.empty();
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (!isFirebaseAvailable) return null;
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    if (isFirebaseAvailable) {
      await _auth.signOut();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (!isFirebaseAvailable) return;
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    await user.updatePassword(newPassword);
  }

  Future<void> reauthenticate(String password) async {
    if (!isFirebaseAvailable) return;
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    final email = user.email ?? '';
    if (email.isEmpty) throw Exception('Email tidak tersedia');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }
}
