import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../services/database_service.dart';

/// Mengambil data AppUser dari Realtime DB berdasarkan uid.
/// null saat belum login / data belum ada di DB.
final userDataProvider = FutureProvider.family<AppUser?, String>((ref, uid) async {
  return ref.read(databaseServiceProvider).getUser(uid);
});

/// Profil user: data kelas/jurusan, ganti foto (placeholder), ubah password,
/// hubungi admin via WA.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Data user dimuat reaktif via userDataProvider di build().
  }

  Future<void> _openAdminWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/${AppConstants.adminWhatsApp}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka WA admin: $uri')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka WA: $e')),
        );
      }
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ganti Password', style: AppTextStyles.sectionTitle),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'Password baru (min. 6 karakter)',
            hintStyle: AppTextStyles.inputHint,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: AppTextStyles.button.copyWith(color: AppColors.primary))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final pw = controller.text.trim();
    if (pw.length < 6) return;

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(pw);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password berhasil diubah', style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'requires-recent-login'
                ? 'Login ulang dulu sebelum ganti password'
                : 'Gagal: ${e.message}',
            style: AppTextStyles.bodyMedium,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber ?? '-';
    final userAsync = user == null ? null : ref.watch(userDataProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil', style: AppTextStyles.welcome.copyWith(fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header profil ----
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.accent,
                      backgroundImage: userAsync?.whenOrNull(
                        data: (u) => u?.photoUrl != null && u!.photoUrl!.isNotEmpty
                            ? NetworkImage(u.photoUrl!) as ImageProvider
                            : null,
                      ),
                      child: userAsync?.whenOrNull(
                        data: (u) => u?.photoUrl == null || u!.photoUrl!.isEmpty
                            ? Icon(Icons.person, size: 52, color: AppColors.iconGold)
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.subtle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  phone,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pelanggan Setia',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---- Info akademik ----
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Nama Lengkap',
                  value: userAsync?.when(
                    data: (u) => u?.name.isNotEmpty == true ? u!.name : '—',
                    loading: () => '…',
                    error: (_, __) => '—',
                  ) ?? '—',
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Username',
                  value: userAsync?.when(
                    data: (u) => u?.username.isNotEmpty == true ? u!.username : '—',
                    loading: () => '…',
                    error: (_, __) => '—',
                  ) ?? '—',
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Jurusan',
                  value: userAsync?.when(
                    data: (u) => u?.jurusan.label ?? '—',
                    loading: () => '…',
                    error: (_, __) => '—',
                  ) ?? '—',
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.class_outlined,
                  label: 'Kelas',
                  value: userAsync?.when(
                    data: (u) => u?.kelas.label ?? '—',
                    loading: () => '…',
                    error: (_, __) => '—',
                  ) ?? '—',
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Nomor Telepon',
                  value: phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---- Aksi ----
          _ActionCard(
            icon: Icons.image_outlined,
            title: 'Ganti Foto Profil',
            subtitle: 'Upload foto dari galeri atau kamera',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fitur upload foto coming soon', style: AppTextStyles.bodyMedium),
                  backgroundColor: AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.lock_outlined,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun Anda',
            onTap: () => _changePassword(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.support_agent_outlined,
            title: 'Hubungi Admin / Buat Ticket',
            subtitle: 'Keluhan, request menu, atau alergi makanan',
            onTap: () => _openAdminWhatsApp(context),
          ),
          const SizedBox(height: 24),

          // ---- Logout button ----
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: Text('Keluar', style: AppTextStyles.buttonLarge),
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Keluar', style: AppTextStyles.sectionTitle),
                    content: Text(
                      'Apakah Anda yakin ingin keluar?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Batal', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Keluar', style: AppTextStyles.button),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/auth');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.divider,
        indent: 16,
        endIndent: 16,
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMediumBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: AppColors.border, width: 0.5),
            ),
            shadows: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMediumBold),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}