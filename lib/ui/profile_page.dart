import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/admin_whatsapp_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/image_upload_service.dart';
import 'shared_widgets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final user = userAsync.value;

    final displayName = (user != null && user.name.isNotEmpty) ? user.name : 'Humiiu';
    final displayUsername = (user != null && user.username.isNotEmpty) ? '@${user.username}' : '@humiiu';
    final displayClass = user != null ? 'Class ${user.kelas.label}' : 'Class XII IPS 2';
    final displayMajor = user != null ? 'Major: ${user.jurusan.label}' : 'Major: MIPA';
    final displayPhone = (user != null && user.phone.isNotEmpty) ? user.phone : '0899-XXXX-XXXX';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(currentUserProfileProvider);
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            children: [
              // Avatar dengan Badge Kamera
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showPhotoActionSheet(context, ref, user),
                      child: Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8DADA), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 80,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.textSecondary,
                                  size: 80,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showPhotoActionSheet(context, ref, user),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Nama Lengkap
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTextStyles.welcome.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              // Username
              Text(
                displayUsername,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              // Tag Kelas & Jurusan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProfileTag(label: displayClass),
                  const SizedBox(width: 8),
                  _ProfileTag(label: displayMajor),
                ],
              ),
              const SizedBox(height: 10),
              // Nomor HP
              Text(
                displayPhone,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Aksi-aksi Profil
              _ProfileAction(
                icon: Icons.badge_outlined,
                color: const Color(0xFFA40B42),
                title: 'Data Siswa & Profil',
                subtitle: 'Nama lengkap, kelas, jurusan & telepon',
                onTap: () => _showEditStudentProfileSheet(context, ref, user),
              ),
              const SizedBox(height: 14),
              _ProfileAction(
                icon: Icons.alternate_email,
                color: const Color(0xFF7B0B33),
                title: 'Ubah Username',
                subtitle: 'Perbarui identitas username login',
                onTap: () => _showChangeUsernameSheet(context, ref, user),
              ),
              const SizedBox(height: 14),
              _ProfileAction(
                icon: Icons.lock_outline,
                color: AppColors.gold,
                title: 'Ubah Password',
                subtitle: 'Password lama, baru, & konfirmasi',
                onTap: () => _showChangePasswordSheet(context, ref),
              ),
              const SizedBox(height: 14),
              _ProfileAction(
                icon: Icons.headset_mic_outlined,
                color: const Color(0xFF9B0053),
                title: 'Hubungi Admin',
                subtitle: 'Bantuan pesanan & layanan katering',
                onTap: () => _showAdminSheet(context, displayName, displayClass),
              ),
              const SizedBox(height: 32),
              // Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmSignOut(context, ref),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    textStyle: AppTextStyles.bodyMediumBold,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PFP BOTTOM SHEET ====================
  void _showPhotoActionSheet(BuildContext context, WidgetRef ref, AppUser? user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil hanya dapat diubah saat akun aktif.')),
      );
      return;
    }

    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Foto Profil',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: Text('Ambil Foto Langsung (Kamera)', style: AppTextStyles.bodyMediumBold),
                subtitle: Text('Gunakan kamera ponsel untuk foto baru', style: AppTextStyles.caption),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _pickAndUploadImage(context, ref, user.uid, ImageSource.camera);
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFFC78C06)),
                ),
                title: Text('Pilih dari Galeri', style: AppTextStyles.bodyMediumBold),
                subtitle: Text('Pilih foto yang sudah ada di perangkat', style: AppTextStyles.caption),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _pickAndUploadImage(context, ref, user.uid, ImageSource.gallery);
                },
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 4),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: Text(
                    'Hapus Foto Profil',
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.error),
                  ),
                  subtitle: Text('Kembalikan ke ikon profil bawaan', style: AppTextStyles.caption),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await _deleteProfilePhoto(context, ref, user.uid);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    WidgetRef ref,
    String uid,
    ImageSource source,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Mengunggah foto profil...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final uploadService = ref.read(imageUploadServiceProvider);
      final downloadUrl = await uploadService.pickAndUpload(source);
      if (downloadUrl == null) return;

      await ref.read(databaseServiceProvider).setProfilePhoto(uid, downloadUrl);
      ref.invalidate(currentUserProfileProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal memperbarui foto profil: $e')),
      );
    }
  }

  Future<void> _deleteProfilePhoto(BuildContext context, WidgetRef ref, String uid) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(imageUploadServiceProvider).deleteProfilePhoto(uid);
      await ref.read(databaseServiceProvider).removeProfilePhoto(uid);
      ref.invalidate(currentUserProfileProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil dihapus')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menghapus foto profil: $e')),
      );
    }
  }

  // ==================== EDIT DATA SISWA BOTTOM SHEET ====================
  void _showEditStudentProfileSheet(BuildContext context, WidgetRef ref, AppUser? user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil belum aktif. Silakan login terlebih dahulu.')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    String selectedKelas = user.kelas.label;
    String selectedJurusan = user.jurusan.label;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Data Siswa & Profil',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Perbarui nama lengkap, kelas, jurusan, atau kontak Anda.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Nama Lengkap
                Text('Nama Lengkap', style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nama lengkap Anda',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Row Kelas & Jurusan
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kelas', style: AppTextStyles.bodyMediumBold),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedKelas,
                            items: kelasOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedKelas = val);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jurusan', style: AppTextStyles.bodyMediumBold),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedJurusan,
                            items: jurusanOptions.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedJurusan = val);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nomor WhatsApp
                Text('Nomor WhatsApp', style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '08xxxxxxxxxx',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 24),

                DemoPrimaryButton(
                  label: 'Simpan Perubahan',
                  isLoading: isSaving,
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newName = nameController.text.trim();
                          final newPhone = phoneController.text.trim();
                          if (newName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama lengkap tidak boleh kosong.')),
                            );
                            return;
                          }

                          setSheetState(() => isSaving = true);
                          try {
                            await ref.read(databaseServiceProvider).updateStudentProfile(
                                  user.uid,
                                  name: newName,
                                  kelas: selectedKelas,
                                  jurusan: selectedJurusan,
                                  phone: newPhone.isNotEmpty ? newPhone : null,
                                );
                            ref.invalidate(currentUserProfileProvider);

                            if (ctx.mounted) Navigator.pop(sheetCtx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data profil berhasil diperbarui!')),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              setSheetState(() => isSaving = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Gagal menyimpan: $e')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== UBAH USERNAME BOTTOM SHEET ====================
  void _showChangeUsernameSheet(BuildContext context, WidgetRef ref, AppUser? user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil belum aktif. Silakan login terlebih dahulu.')),
      );
      return;
    }

    final usernameController = TextEditingController(text: user.username);
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ubah Username',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Username digunakan untuk login ke aplikasi Dian Catering.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Text('Username Baru', style: AppTextStyles.bodyMediumBold),
              const SizedBox(height: 6),
              TextField(
                controller: usernameController,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixText: '@ ',
                  prefixStyle: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                  hintText: 'username_baru',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 24),
              DemoPrimaryButton(
                label: 'Simpan Username',
                isLoading: isSaving,
                onPressed: isSaving
                    ? null
                    : () async {
                        final newUsn = usernameController.text.trim().toLowerCase();
                        if (newUsn.length < 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Username minimal 3 karakter.')),
                          );
                          return;
                        }

                        if (newUsn == user.username.toLowerCase()) {
                          Navigator.pop(sheetCtx);
                          return;
                        }

                        setSheetState(() => isSaving = true);
                        try {
                          await ref.read(databaseServiceProvider).changeUsername(
                                user.uid,
                                user.username,
                                newUsn,
                              );
                          await ref.read(authServiceProvider).updateVirtualEmail(newUsn);
                          ref.invalidate(currentUserProfileProvider);

                          if (ctx.mounted) Navigator.pop(sheetCtx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Username berhasil diubah menjadi @$newUsn')),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setSheetState(() => isSaving = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(e.toString().replaceAll('Exception: ', '')),
                              ),
                            );
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UBAH PASSWORD BOTTOM SHEET (3-FIELDS) ====================
  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Ubah Password',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masukkan password saat ini untuk verifikasi keamanan.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Field 1: Password Lama
                Text('Password Saat Ini (Lama)', style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: 6),
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    hintText: 'Password lama Anda',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 2: Password Baru
                Text('Password Baru', style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: 6),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 3: Konfirmasi Password Baru
                Text('Konfirmasi Password Baru', style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password baru',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                DemoPrimaryButton(
                  label: 'Simpan Password Baru',
                  isLoading: isSaving,
                  onPressed: isSaving
                      ? null
                      : () async {
                          final currentPass = currentPasswordController.text;
                          final newPass = newPasswordController.text;
                          final confirmPass = confirmPasswordController.text;

                          if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Semua field password harus diisi.')),
                            );
                            return;
                          }

                          setSheetState(() => isSaving = true);
                          try {
                            await ref.read(authServiceProvider).changePassword(
                                  currentPassword: currentPass,
                                  newPassword: newPass,
                                  confirmPassword: confirmPass,
                                );

                            if (ctx.mounted) Navigator.pop(sheetCtx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password berhasil diubah!')),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              setSheetState(() => isSaving = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGOUT CONFIRMATION ====================
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Logout', style: AppTextStyles.bodyMediumBold),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Dian Catering?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ==================== ADMIN WHATSAPP SHEET ====================
  void _showAdminSheet(BuildContext context, String userName, String userClass) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
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
            title: 'Keluhan layanan',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.complaint,
                name: userName,
                kelas: userClass,
                details: 'Ada kendala pada pesanan katering',
              );
            },
          ),
          _AdminSheetOption(
            title: 'Bantuan umum / konsultasi',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.other,
                name: userName,
                kelas: userClass,
                details: 'Saya butuh bantuan terkait akun atau pesanan',
              );
            },
          ),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Hubungi Admin Katering',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDEA5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMediumBold),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
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
