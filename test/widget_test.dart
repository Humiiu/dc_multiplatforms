import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dc_multiplatforms/main.dart';
import 'package:dc_multiplatforms/ui/demo_state.dart';
import 'package:dc_multiplatforms/ui/history_page.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('demo order state updates selections and totals locally', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(demoOrderProvider.notifier);

    DemoOrderState state() => container.read(demoOrderProvider);

    expect(state().total, 40000);
    notifier.toggleDay('rabu');
    expect(state().total, 60000);
    notifier.toggleDay('senin');
    expect(state().total, 40000);

    notifier.addDemoOrder();
    expect(state().orders.first.amount, 40000);
    expect(state().orders.first.days, ['Selasa', 'Rabu']);
    expect(state().orders.first.isPaid, isFalse);

    notifier.prepareDebtPayment(
      450000,
      targetWeek: 'Oktober, Minggu 2',
    );
    notifier.addDemoOrder();
    final settledDebt = state().orders.firstWhere(
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
    expect(
      tester.widget<Text>(find.text('Register')).style?.color,
      Colors.white,
    );

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(
      tester.allWidgets.whereType<Text>().any(
            (text) => text.data?.endsWith(', Humiiu!') ?? false,
          ),
      isTrue,
    );
    expect(find.text('DEBT LEFT', skipOffstage: false), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('history payment status is represented by icons only',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('hhhhhhhhhhhhhhistory'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Sudah Lunas'), findsOneWidget);
    expect(find.text('Belum Lunas'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(
      tester
          .widgetList<Icon>(find.byIcon(Icons.check_circle_outline))
          .first
          .size,
      12,
    );
    await tester.scrollUntilVisible(
      find.text('Rp 450.000'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
