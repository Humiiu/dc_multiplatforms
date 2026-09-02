import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/database_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService(this.ref);

  /// Register user with full data
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

  /// Login with phone + password
  Future<User?> signInWithEmailAndPassword(String phone, String password) async {
    final db = ref.read(databaseServiceProvider);
    final uid = await db.getUidByPhone(phone);

    if (uid == null) {
      throw Exception('Akun tidak ditemukan. Silakan daftar terlebih dahulu.');
    }

    // New Format: phone-based email
    final email = '${phone.replaceAll('+', '')}@catering.app';
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// Create user with email/password
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

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    await user.updatePassword(newPassword);
  }

  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Tidak ada user yang login');
    final email = user.email ?? '';
    if (email.isEmpty) throw Exception('Email tidak tersedia');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }
}