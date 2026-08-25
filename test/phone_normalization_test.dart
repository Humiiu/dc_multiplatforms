// Tests for normalizeIndonesianPhone utility.
import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/widgets/logo_widget.dart' show normalizeIndonesianPhone;

void main() {
  group('normalizeIndonesianPhone', () {
    test('accepts 8xx local format', () {
      expect(normalizeIndonesianPhone('8999107194'), '+628999107194');
    });

    test('accepts 08xx format and strips leading zero', () {
      expect(normalizeIndonesianPhone('08999107194'), '+628999107194');
    });

    test('accepts +62 format without double prefix', () {
      expect(normalizeIndonesianPhone('+628999107194'), '+628999107194');
    });

    test('accepts 62 format without double prefix', () {
      expect(normalizeIndonesianPhone('628999107194'), '+628999107194');
    });

    test('strips spaces, dashes, parens', () {
      expect(normalizeIndonesianPhone('0899-9107-194'), '+628999107194');
      expect(normalizeIndonesianPhone('(0899) 9107 194'), '+628999107194');
      expect(normalizeIndonesianPhone('899 9107 194'), '+628999107194');
    });

    test('rejects empty input', () {
      expect(normalizeIndonesianPhone(''), isNull);
      expect(normalizeIndonesianPhone('   '), isNull);
    });

    test('rejects non-mobile prefixes (landline)', () {
      expect(normalizeIndonesianPhone('0217654321'), isNull);
      expect(normalizeIndonesianPhone('12345678'), isNull);
    });

    test('rejects too-short numbers', () {
      expect(normalizeIndonesianPhone('08123'), isNull);
    });

    test('rejects too-long numbers', () {
      expect(normalizeIndonesianPhone('081234567890123456'), isNull);
    });

    test('rejects letters mixed in', () {
      // raw letters fail the digit check
      expect(normalizeIndonesianPhone('08a107194x'), isNull);
      expect(normalizeIndonesianPhone('abc'), isNull);
    });
  });
}