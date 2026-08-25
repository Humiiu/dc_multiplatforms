import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/auth_page.dart';
import 'screens/main_shell.dart';
import 'screens/home/home_page.dart';
import 'screens/order/order_page.dart';
import 'screens/checkout/checkout_page.dart';
import 'screens/history/history_page.dart';
import 'screens/profile/profile_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return state.matchedLocation == '/auth' ? null : '/auth';
    }
    if (state.matchedLocation == '/auth') return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    // Checkout di luar shell (fullscreen, tanpa navbar).
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    // Halaman utama memakai ShellRoute agar punya bottom navbar.
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/order',
          builder: (context, state) => const OrderPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
