import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _index(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/order')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    const destinations = ['/home', '/order', '/history', '/profile'];
    context.go(destinations[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SizedBox(
        height: 64,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A9E013A),
                          blurRadius: 8,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _NavItem(
                          label: 'Home',
                          selected: _index(context) == 0,
                          icon: _index(context) == 0
                              ? Icons.home
                              : Icons.home_outlined,
                          onTap: () => _navigate(context, 0),
                        ),
                        _NavItem(
                          label: 'Order',
                          selected: _index(context) == 1,
                          icon: Icons.restaurant_menu,
                          onTap: () => _navigate(context, 1),
                        ),
                        _NavItem(
                          label: 'History',
                          selected: _index(context) == 2,
                          icon: Icons.history,
                          onTap: () => _navigate(context, 2),
                        ),
                        _NavItem(
                          label: 'Profile',
                          selected: _index(context) == 3,
                          icon: _index(context) == 3
                              ? Icons.person
                              : Icons.person_outline,
                          onTap: () => _navigate(context, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF4A3A3A);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
