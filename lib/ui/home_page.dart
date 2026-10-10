import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/greetings.dart';
import '../core/theme.dart';
import '../services/admin_whatsapp_service.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const List<_WeeklyMenuItem> _weeklyMenus = [
    _WeeklyMenuItem(
      date: 'Senin, 27 Okt',
      title: 'Nasi Liwet Ayam Goreng',
      subtitle: 'Tempe goreng, sambal',
    ),
    _WeeklyMenuItem(
      date: 'Selasa, 28 Okt',
      title: 'Ayam Telur Asin',
      subtitle: 'Martabak tahu, kacang panjang',
    ),
    _WeeklyMenuItem(
      date: 'Rabu, 29 Okt',
      title: 'Ayam Hot Lava',
      subtitle: 'Tahu krispi, timun',
    ),
    _WeeklyMenuItem(
      date: 'Kamis, 30 Okt',
      title: 'Ayam Teriyaki',
      subtitle: 'Nasi, sayuran, wijen',
    ),
    _WeeklyMenuItem(
      date: 'Jumat, 31 Okt',
      title: 'Nasi Goreng Spesial',
      subtitle: 'Telur, ayam suwir, kerupuk',
    ),
  ];

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final String _greeting;
  late final PageController _menuController;
  Timer? _menuTimer;

  @override
  void initState() {
    super.initState();
    _greeting = getRandomGreeting();
    _menuController = PageController(viewportFraction: 0.72);
    _menuTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_menuController.hasClients) return;
      final currentPage = _menuController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % HomePage._weeklyMenus.length;
      _menuController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _menuTimer?.cancel();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          children: [
            const DemoTopBar(),
            const SizedBox(height: 8),
            Text(
              'WELCOME',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              '$_greeting, Humiiu!',
              style: AppTextStyles.welcome.copyWith(
                fontSize: 29,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _DebtCard(
              onTap: () {
                ref.read(demoOrderProvider).prepareDebtPayment(60000);
                context.push('/checkout');
              },
            ),
            const SizedBox(height: 26),
            DemoSectionTitle(
              title: 'Weekly Menu',
              trailing: TextButton(
                onPressed: () => context.go('/order'),
                child: const Text('See All ›'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 218,
              child: PageView.builder(
                controller: _menuController,
                itemCount: HomePage._weeklyMenus.length,
                itemBuilder: (context, index) {
                  final item = HomePage._weeklyMenus[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _MenuCard(
                      date: item.date,
                      title: item.title,
                      subtitle: item.subtitle,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            _PreferenceCard(
              onTap: () => _showAdminSheet(context),
            ),
            const SizedBox(height: 24),
            DemoPrimaryButton(
              label: 'Start Buying!',
              onPressed: () => context.go('/order'),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
                details: 'Tidak suka pedas dan alergi kacang',
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
                details: 'Pesanan minggu ini kurang sesuai jadwal pengiriman',
              );
            },
          ),
          _AdminSheetOption(
            title: 'Hutang / bayar hutang',
            onTap: () {
              Navigator.pop(sheetContext);
              AdminWhatsappService.open(
                purpose: AdminWhatsappPurpose.debtPayment,
                name: 'Humiiu',
                kelas: 'XII IPS 2',
                total: 60000,
                periode: 'Oktober, Minggu 2',
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
                details: 'Saya butuh bantuan terkait jadwal pengiriman',
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
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

class _WeeklyMenuItem {
  final String date;
  final String title;
  final String subtitle;

  const _WeeklyMenuItem({
    required this.date,
    required this.title,
    required this.subtitle,
  });
}

class _DebtCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DebtCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.cardElevated,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -0.9),
                    radius: 1.4,
                    colors: [AppColors.surfaceVariant, Colors.white],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'DEBT LEFT',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Center(
                          child: Icon(Icons.circle,
                              color: AppColors.error, size: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.priceLarge.copyWith(fontSize: 42),
                      children: const [
                        TextSpan(
                          text: 'Rp ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: '60.000'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DemoPrimaryButton(
                    label: 'Pay Now',
                    icon: Icons.arrow_forward,
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;

  const _MenuCard({
    required this.date,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.cardElevated,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFE0A8), Colors.white],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            date,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.bodyMediumBold),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PreferenceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: const BoxDecoration(color: AppColors.surfaceVariant),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: -1,
              top: -1,
              child: _CornerBlob(size: 80, roundBottomLeft: true),
            ),
            Positioned(
              left: -1,
              bottom: -1,
              child: _CornerBlob(size: 64, roundTopRight: true),
            ),
            Column(
              children: [
                Transform.rotate(
                  angle: -0.12,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.peach,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.star_border,
                        color: AppColors.iconGold, size: 35),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Punya request khusus?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    'Beri tahu kami jika ada alergi atau saran makanan untuk pesanan Anda berikutnya.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.bodyMediumBold,
                  ),
                  child: const Text('Atur Preferensi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBlob extends StatelessWidget {
  final double size;
  final bool roundBottomLeft;
  final bool roundTopRight;

  const _CornerBlob({
    required this.size,
    this.roundBottomLeft = false,
    this.roundTopRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.blobPink,
        borderRadius: BorderRadius.only(
          bottomLeft: roundBottomLeft ? Radius.circular(size) : Radius.zero,
          topRight: roundTopRight ? Radius.circular(size) : Radius.zero,
        ),
      ),
    );
  }
}
