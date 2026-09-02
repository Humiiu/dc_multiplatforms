import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/logo_widget.dart';
import 'main_shell.dart';

/// Responsive shell yang menggunakan top-nav pada desktop (>= 900px)
/// dan menggunakan MainShell (bottom-nav) pada mobile.
class WebShell extends ConsumerWidget {
  final Widget child;

  const WebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return _DesktopShell(child: child);
    }
    return MainShell(child: child);
  }
}

class _DesktopShell extends ConsumerWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: [
                const AppLogo(size: 40),
                const SizedBox(width: 12),
                Text(
                  'Catering Booking',
                  style: AppTextStyles.welcome.copyWith(fontSize: 20),
                ),
                const Spacer(),
                _DesktopNavLink(
                  label: 'Beranda',
                  isSelected: location == '/home',
                  onTap: () => context.go('/home'),
                ),
                _DesktopNavLink(
                  label: 'Pesan',
                  isSelected: location == '/order',
                  onTap: () => context.go('/order'),
                ),
                _DesktopNavLink(
                  label: 'Riwayat',
                  isSelected: location == '/history',
                  onTap: () => context.go('/history'),
                ),
                _DesktopNavLink(
                  label: 'Profil',
                  isSelected: location == '/profile',
                  onTap: () => context.go('/profile'),
                ),
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/admin/dashboard'),
                      icon: const Icon(Icons.admin_panel_settings, size: 18),
                      label: const Text('Panel Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }
}

class _DesktopNavLink extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopNavLink({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
