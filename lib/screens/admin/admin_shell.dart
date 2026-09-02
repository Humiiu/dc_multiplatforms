import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

/// Shell untuk halaman admin (website/desktop).
/// Menyediakan sidebar navigasi kiri + content area pada layar lebar,
/// dan drawer/bottom nav pada layar kecil.
class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const _destinations = [
    (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
    (icon: Icons.restaurant_menu_outlined, selectedIcon: Icons.restaurant_menu, label: 'Menu', route: '/admin/menu'),
    (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Pesanan', route: '/admin/orders'),
    (icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Siswa', route: '/admin/users'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  Widget _navItem(BuildContext context, int index) {
    final dest = _destinations[index];
    final selected = _currentIndex(context) == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return ListTile(
      leading: Icon(
        selected ? dest.selectedIcon : dest.icon,
        color: color,
      ),
      title: Text(
        dest.label,
        style: AppTextStyles.bodyMediumBold.copyWith(color: color),
      ),
      selected: selected,
      selectedTileColor: AppColors.secondary.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onTap: () => context.go(dest.route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      // Layout desktop: sidebar tetap + konten.
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sidebar
            Container(
              width: 240,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.gradientPrimary,
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Catering Admin',
                              style: AppTextStyles.sectionTitle,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    for (var i = 0; i < _destinations.length; i++)
                      _navItem(context, i),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali ke Aplikasi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: AppColors.background,
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Layout kecil & mobile: AppBar + bottom nav.
    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_currentIndex(context)].label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_destinations[i].route),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
