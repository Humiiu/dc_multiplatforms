import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/services/auth_service.dart';

void main() {
  group('AuthService.maskUsernameToEmail', () {
    test('masks standard lowercase username', () {
      expect(
        AuthService.maskUsernameToEmail('humiiu'),
        'humiiu@diancatering.app',
      );
    });

    test('masks mixed-case username to lowercase', () {
      expect(
        AuthService.maskUsernameToEmail('Humiiu14'),
        'humiiu14@diancatering.app',
      );
    });

    test('strips leading and trailing whitespaces', () {
      expect(
        AuthService.maskUsernameToEmail('  siswa_rpl  '),
        'siswa_rpl@diancatering.app',
      );
    });

    test('sanitizes unsupported characters like spaces or special symbols', () {
      expect(
        AuthService.maskUsernameToEmail('john doe#1!'),
        'johndoe1@diancatering.app',
      );
    });
  });
}

