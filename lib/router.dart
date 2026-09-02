import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'main.dart' show appContainer;
import 'providers/admin_provider.dart';
import 'screens/auth/auth_page.dart';
import 'screens/web_shell.dart';
import 'screens/home/home_page.dart';
import 'screens/order/order_page.dart';
import 'screens/checkout/checkout_page.dart';
import 'screens/history/history_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/admin_dashboard_page.dart';
import 'screens/admin/admin_menu_page.dart';
import 'screens/admin/admin_orders_page.dart';
import 'screens/admin/admin_users_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  refreshListenable: appContainer.read(adminRoleCacheProvider),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    // Belum login -> ke halaman auth.
    if (user == null) {
      return state.matchedLocation == '/auth' ? null : '/auth';
    }
    if (state.matchedLocation == '/auth') return '/home';

    // Route admin: cek role. 
    if (state.matchedLocation.startsWith('/admin')) {
      final cache = appContainer.read(adminRoleCacheProvider);
      // Jika belum termuat, jangan redirect dulu (tunggu refreshListenable memicu ulang).
      if (!cache.loaded) return null; 
      // Jika sudah termuat tapi bukan admin -> ke home.
      if (!cache.isAdmin) return '/home';
    }

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
    // Halaman utama memakai ShellRoute agar punya responsive top-nav / bottom navbar.
    ShellRoute(
      builder: (context, state, child) => WebShell(child: child),
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
    // Panel admin (hanya untuk role admin).
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/menu',
          builder: (context, state) => const AdminMenuPage(),
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (context, state) => const AdminOrdersPage(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const AdminUsersPage(),
        ),
      ],
    ),
  ],
);
