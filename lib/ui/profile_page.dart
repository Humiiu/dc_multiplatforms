import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../services/admin_whatsapp_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final user = userAsync.value;

    final displayName = (user != null && user.name.isNotEmpty) ? user.name : 'Humiiu';
    final displayClass = user != null ? 'Class ${user.kelas.label}' : 'Class XII IPS 2';
    final displayMajor = user != null ? 'Major: ${user.jurusan.label}' : 'Major: MIPA';
    final displayPhone = (user != null && user.phone.isNotEmpty) ? user.phone : '0899-XXXX-XXXX';

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
              displayName,
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
                _ProfileTag(label: displayClass),
                const SizedBox(width: 8),
                _ProfileTag(label: displayMajor),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              displayPhone,
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
              onTap: () => _showEditProfileDialog(context, ref, user),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.lock_outline,
              color: AppColors.gold,
              title: 'Ubah Password',
              subtitle: 'Secure your account',
              onTap: () => _showChangePasswordDialog(context, ref),
            ),
            const SizedBox(height: 14),
            _ProfileAction(
              icon: Icons.headset_mic_outlined,
              color: const Color(0xFF9B0053),
              title: 'Hubungi Admin',
              subtitle: 'Get help with your orders',
              onTap: () => _showAdminSheet(context, displayName, displayClass),
            ),
            const SizedBox(height: 36),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                },
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

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, dynamic user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil belum tersedia pada mode demo.')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.name as String);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(dialogCtx);
              try {
                await ref.read(databaseServiceProvider).updateUser(user.uid as String, {'name': newName});
                ref.invalidate(currentUserProfileProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui profil: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Password Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Minimal 6 karakter',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newPass = passwordController.text.trim();
              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password minimal 6 karakter')),
                );
                return;
              }
              Navigator.pop(dialogCtx);
              try {
                await ref.read(authServiceProvider).updatePassword(newPass);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengubah password: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAdminSheet(BuildContext context, String userName, String userClass) {
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
                name: userName,
                kelas: userClass,
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
                name: userName,
                kelas: userClass,
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
                name: userName,
                kelas: userClass,
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
                name: userName,
                kelas: userClass,
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
