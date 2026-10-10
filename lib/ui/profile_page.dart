import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/admin_whatsapp_service.dart';

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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8DADA)),
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
              color: const Color(0xFFA40B42),
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => _showDemoDialog(context, 'Edit Profile'),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.lock_outline,
              color: AppColors.gold,
              title: 'Ubah Password',
              subtitle: 'Secure your account',
              onTap: () => _showDemoDialog(context, 'Ubah Password'),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.headset_mic_outlined,
              color: const Color(0xFF9B0053),
              title: 'Hubungi Admin',
              subtitle: 'Get help with your orders',
              onTap: () => _showAdminSheet(context),
            ),
            const SizedBox(height: 36),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/auth'),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  textStyle: AppTextStyles.bodyMediumBold,
                ),
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

  void _showAdminSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final options = [
          _AdminSheetOption(
            title: 'Request menu khusus',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.menuRequest,
                name: 'Humiiu',
                kelas: 'XII IPS 2',
                details: 'Menu favorit saya...',
              );
            },
          ),
          _AdminSheetOption(
            title: 'Alergi / preferensi makanan',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.allergyPreference,
                name: 'Humiiu',
                kelas: 'XII IPS 2',
                details: 'Saya tidak suka pedas dan alergi kacang',
              );
            },
          ),
          _AdminSheetOption(
            title: 'Keluhan',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.complaint,
                name: 'Humiiu',
                kelas: 'XII IPS 2',
                details: 'Ada masalah pada pengiriman minggu ini',
              );
            },
          ),
          _AdminSheetOption(
            title: 'Butuh bantuan lain',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.other,
                name: 'Humiiu',
                kelas: 'XII IPS 2',
                details: 'Saya butuh bantuan terkait pesanan saya',
              );
            },
          ),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Hubungi Admin',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      tileColor: AppColors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        option.title,
                        style: AppTextStyles.bodyMediumBold,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      onTap: option.onTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminSheetOption {
  final String title;
  final VoidCallback onTap;

  const _AdminSheetOption({
    required this.title,
    required this.onTap,
  });
}

class _ProfileTag extends StatelessWidget {
  final String label;

  const _ProfileTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDEA5),
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
      color: const Color(0xFFFFEBCD),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    ),
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
