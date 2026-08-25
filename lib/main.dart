import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase.dart';
import 'core/theme.dart';
import 'router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseInitializer(
      child: MaterialApp.router(
        title: 'Catering Booking',
        theme: buildAppTheme(),
        routerConfig: appRouter,
        // navigatorKey is not available on MaterialApp.router
        // We'll use a different approach for cross-context navigation
      ),
    );
  }
}