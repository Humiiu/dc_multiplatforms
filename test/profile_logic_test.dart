import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dc_multiplatforms/services/auth_service.dart';

void main() {
  group('Profile Password Change Validation Tests', () {
    test('changePassword rejects password shorter than 6 characters', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final auth = container.read(authServiceProvider);

      expect(
        () => auth.changePassword(
          currentPassword: 'oldpassword123',
          newPassword: '123',
          confirmPassword: '123',
        ),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains('Password baru minimal 6 karakter')),
        ),
      );
    });

    test('changePassword rejects mismatched new password and confirmation',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final auth = container.read(authServiceProvider);

      expect(
        () => auth.changePassword(
          currentPassword: 'oldpassword123',
          newPassword: 'newpassword123',
          confirmPassword: 'wrongconfirm123',
        ),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains('Konfirmasi password baru tidak cocok')),
        ),
      );
    });

    test('changePassword rejects identical new and old password', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final auth = container.read(authServiceProvider);

      expect(
        () => auth.changePassword(
          currentPassword: 'samepassword123',
          newPassword: 'samepassword123',
          confirmPassword: 'samepassword123',
        ),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains('tidak boleh sama')),
        ),
      );
    });

    test('changePassword succeeds/simulates gracefully when Firebase offline',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final auth = container.read(authServiceProvider);

      // Should complete without throwing when validations pass in test/offline mode
      await expectLater(
        auth.changePassword(
          currentPassword: 'oldpassword123',
          newPassword: 'newpassword123',
          confirmPassword: 'newpassword123',
        ),
        completes,
      );
    });
  });
}
