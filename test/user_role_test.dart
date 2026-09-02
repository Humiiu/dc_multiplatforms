// Tests for AppUser role serialization (user/admin) used by the web admin panel.
import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/models/user.dart';

void main() {
  group('UserRoleExtension', () {
    test('fromLabel maps admin -> UserRole.admin', () {
      expect(UserRoleExtension.fromLabel('admin'), UserRole.admin);
    });

    test('fromLabel is case-insensitive', () {
      expect(UserRoleExtension.fromLabel('Admin'), UserRole.admin);
      expect(UserRoleExtension.fromLabel('ADMIN'), UserRole.admin);
    });

    test('fromLabel defaults unknown/null to user', () {
      expect(UserRoleExtension.fromLabel(null), UserRole.user);
      expect(UserRoleExtension.fromLabel('owner'), UserRole.user);
      expect(UserRoleExtension.fromLabel(''), UserRole.user);
    });

    test('label roundtrip', () {
      expect(UserRole.user.label, 'user');
      expect(UserRole.admin.label, 'admin');
    });
  });

  group('AppUser role serialization', () {
    AppUser user({
      UserRole role = UserRole.user,
      String? roleKey,
    }) {
      final finalRoleKey = roleKey ?? role.label;
      final map = <String, dynamic>{
        'username': 'budi',
        'phone': '+628999107194',
        'name': 'Budi',
        'jurusan': 'RPL',
        'kelas': 'XI',
        'createdAt': 0,
        'role': finalRoleKey,
      };
      return AppUser.fromMap('uid1', map);
    }

    test('fromMap reads admin role', () {
      expect(user(roleKey: 'admin').role, UserRole.admin);
    });

    test('fromMap defaults missing role to user', () {
      final map = <String, dynamic>{
        'username': 'budi',
        'phone': '+628999107194',
        'name': 'Budi',
        'jurusan': 'RPL',
        'kelas': 'XI',
        'createdAt': 0,
      };
      expect(AppUser.fromMap('uid1', map).role, UserRole.user);
    });

    test('toMap persists role', () {
      final u = AppUser(
        uid: 'uid1',
        username: 'budi',
        phone: '+628999107194',
        name: 'Budi',
        jurusan: Jurusan.rpl,
        kelas: Kelas.xii,
        role: UserRole.admin,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(u.toMap()['role'], 'admin');
    });

    test('toMap defaults to user role label when not set', () {
      final u = user();
      expect(u.toMap()['role'], 'user');
    });

    test('isAdmin getter', () {
      expect(user(role: UserRole.admin).isAdmin, isTrue);
      expect(user().isAdmin, isFalse);
    });

    test('copyWith preserves role when not overridden and updates when set', () {
      final admin = user(role: UserRole.admin);
      expect(admin.copyWith(name: 'X').role, UserRole.admin);
      expect(admin.copyWith(role: UserRole.user).role, UserRole.user);
    });
  });
}
