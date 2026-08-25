// Tests for normalizeIndonesianPhone utility and PhoneInputFormatter.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/widgets/logo_widget.dart'
    show normalizeIndonesianPhone, PhoneInputFormatter;

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

  group('PhoneInputFormatter', () {
    final formatter = PhoneInputFormatter();

    TextEditingValue formatText(String text, [int cursorPos = -1]) {
      final old = const TextEditingValue();
      final sel = cursorPos >= 0
          ? TextSelection.collapsed(offset: cursorPos)
          : TextSelection.collapsed(offset: text.length);
      return formatter.formatEditUpdate(old, TextEditingValue(text: text, selection: sel));
    }

    test('formats single digit', () {
      final result = formatText('8');
      expect(result.text, '8');
    });

    test('formats 4 digits with dash after 4th', () {
      final result = formatText('8999');
      expect(result.text, '8999');
    });

    test('formats 5 digits with dash', () {
      final result = formatText('89991');
      expect(result.text, '8999-1');
    });

    test('formats full 10-digit number', () {
      final result = formatText('8999107194');
      expect(result.text, '8999-107-194');
    });

    test('strips non-digit characters', () {
      final result = formatText('8999-107-194');
      expect(result.text, '8999-107-194');
    });

    test('strips letters', () {
      final result = formatText('abc8999107194');
      expect(result.text, '8999-107-194');
    });

    test('limits to 12 digits max', () {
      final result = formatText('89991071940000');
      expect(result.text, '8999-107-19400');
    });

    test('strips leading zero', () {
      final result = formatText('08999107194');
      expect(result.text, '8999-107-194');
    });

    test('strips leading 62', () {
      final result = formatText('628999107194');
      expect(result.text, '8999-107-194');
    });

    test('empty input returns empty', () {
      final result = formatText('');
      expect(result.text, '');
    });

    test('formatted text normalizes correctly', () {
      final result = formatText('8999107194');
      // normalizeIndonesianPhone should strip +62, spaces, dashes
      expect(normalizeIndonesianPhone(result.text), '+628999107194');
    });
  });
}