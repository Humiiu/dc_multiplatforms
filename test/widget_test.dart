import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dc_multiplatforms/main.dart';
import 'package:dc_multiplatforms/ui/demo_state.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('demo order state updates selections and totals locally', () {
    final state = DemoOrderState();

    expect(state.total, 40000);
    state.toggleDay('rabu');
    expect(state.total, 60000);
    state.toggleDay('senin');
    expect(state.total, 40000);

    state.addDemoOrder();
    expect(state.orders.first.amount, 40000);
    expect(state.orders.first.days, ['Selasa', 'Rabu']);
    expect(state.orders.first.isPaid, isFalse);

    state.prepareDebtPayment(
      450000,
      targetWeek: 'Oktober, Minggu 2',
    );
    state.addDemoOrder();
    final settledDebt = state.orders.firstWhere(
      (order) => order.week == 'Oktober, Minggu 2',
    );
    expect(settledDebt.isPaid, isTrue);
  });

  testWidgets('auth tabs and demo login reach the home screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 935);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME'), findsOneWidget);
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly Menu'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
