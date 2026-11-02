import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/core/order_validator.dart';

void main() {
  group('OrderValidator Tests', () {
    test('calculateTotal applies flat Rp 20.000 per day', () {
      expect(OrderValidator.calculateTotal(0), 0);
      expect(OrderValidator.calculateTotal(1), 20000);
      expect(OrderValidator.calculateTotal(3), 60000);
      expect(OrderValidator.calculateTotal(5), 100000);
    });

    test('canUsePayLater allows up to Rp 100.000 total debt limit', () {
      // Current 0 + new 40.000 -> allowed
      expect(OrderValidator.canUsePayLater(currentDebt: 0, newOrderAmount: 40000), isTrue);

      // Current 60.000 + new 40.000 = 100.000 -> allowed (exactly at ceiling)
      expect(OrderValidator.canUsePayLater(currentDebt: 60000, newOrderAmount: 40000), isTrue);

      // Current 60.000 + new 60.000 = 120.000 -> rejected
      expect(OrderValidator.canUsePayLater(currentDebt: 60000, newOrderAmount: 60000), isFalse);

      // Current 100.000 + new 20.000 -> rejected
      expect(OrderValidator.canUsePayLater(currentDebt: 100000, newOrderAmount: 20000), isFalse);
    });

    test('isWithinCutoff validates 21:30 WIB limit correctly', () {
      // 10:00 AM -> true
      expect(OrderValidator.isWithinCutoff(DateTime(2026, 11, 2, 10, 0)), isTrue);

      // 21:29 PM -> true
      expect(OrderValidator.isWithinCutoff(DateTime(2026, 11, 2, 21, 29)), isTrue);

      // 21:30 PM -> true (exactly at cut-off)
      expect(OrderValidator.isWithinCutoff(DateTime(2026, 11, 2, 21, 30)), isTrue);

      // 21:31 PM -> false (past cut-off)
      expect(OrderValidator.isWithinCutoff(DateTime(2026, 11, 2, 21, 31)), isFalse);

      // 23:45 PM -> false
      expect(OrderValidator.isWithinCutoff(DateTime(2026, 11, 2, 23, 45)), isFalse);
    });
  });
}
