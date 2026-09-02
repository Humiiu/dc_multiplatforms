import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'router.dart';
import 'utils/configure_non_web.dart' if (dart.library.html) 'utils/configure_web.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Container global Riverpod, dibagikan ke ProviderScope dan router
/// (agar redirect bisa membaca status admin secara sinkron).
final appContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(UncontrolledProviderScope(
    container: appContainer,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catering Booking',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}