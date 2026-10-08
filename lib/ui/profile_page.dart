import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 46, 28, 24),
          children: [
            Center(
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 82,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Humiiu',
              textAlign: TextAlign.center,
              style: AppTextStyles.welcome.copyWith(
                color: AppColors.textPrimary,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileTag(label: 'Class XII IPS 2'),
                const SizedBox(width: 8),
                _ProfileTag(label: 'Major: MIPA'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '0899-XXXX-XXXX',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 42),
            _ProfileAction(
              icon: Icons.edit_outlined,
              color: AppColors.primary,
              title: 'Edit Profile',
              subtitle: 'update',
              onTap: () => _showDemoDialog(context, 'Edit Profile'),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.lock_outline,
              color: AppColors.gold,
              title: 'Ubah Password',
              subtitle: 'pw',
              onTap: () => _showDemoDialog(context, 'Ubah Password'),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.headset_mic_outlined,
              color: AppColors.primary,
              title: 'Hubungi Admin',
              subtitle: 'pengen curhat? yu sini',
              onTap: () => _showDemoDialog(context, 'Hubungi Admin'),
            ),
            const SizedBox(height: 36),
            TextButton.icon(
              onPressed: () => context.go('/auth'),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: AppTextStyles.bodyMediumBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoDialog(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Aksi ini belum terhubung ke backend.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  final String label;

  const _ProfileTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMediumBold),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
