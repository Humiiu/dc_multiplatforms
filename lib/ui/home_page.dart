import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/greetings.dart';
import '../core/theme.dart';
import '../services/admin_whatsapp_service.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late String _greeting;
  late final PageController _menuController;
  Timer? _menuTimer;

  Future<void> _onRefresh() async {
    // TODO(backend): refresh menu mingguan, status tagihan, dan profil user dari Firebase/API.
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _greeting = getRandomGreeting();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _greeting = getRandomGreeting();
    _menuController = PageController(viewportFraction: 0.70);
    _menuTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_menuController.hasClients) return;
      final currentPage = _menuController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % _kMenus.length;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            DemoTopBar(showBrand: true, onHelpTap: () => _showHelpSheet(context)),
            const SizedBox(height: 8),
            Text('WELCOME', style: AppText.overline),
            const SizedBox(height: 4),
            Text('$_greeting, Humiiu!', style: AppText.greeting),
            const SizedBox(height: 24),
            _DebtCard(
              onTap: () {
                ref.read(demoOrderProvider.notifier).prepareDebtPayment(60000);
                context.push('/checkout');
              },
            ),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Weekly Menu',
              onSeeAll: () => context.push('/order'),
            ),
            const SizedBox(height: 14),
            _MenuCarousel(
              controller: _menuController,
              menus: _kMenus,
            ),
            const SizedBox(height: 32),
            _RequestCard(onTap: () => _showAdminSheet(context)),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Start Buying!',
              onPressed: () => context.push('/order'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D8D6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Panduan & Informasi',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                const _HelpInfoTile(
                  icon: Icons.access_time_rounded,
                  title: 'Batas Waktu Order',
                  description:
                      'Pemesanan untuk menu esok hari ditutup setiap malam maksimal pukul 21:30 WIB.',
                ),
                const SizedBox(height: 12),
                const _HelpInfoTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Ketentuan Pay Later (Ngutang)',
                  description:
                      'Maksimal plafon tagihan berjalan adalah Rp 100.000. Pelunasan dilakukan setiap hari Jumat / akhir minggu.',
                ),
                const SizedBox(height: 12),
                const _HelpInfoTile(
                  icon: Icons.chat_outlined,
                  title: 'Hubungi Admin',
                  description:
                      'Perlu konfirmasi pembayaran atau punya pertanyaan? Hubungi admin katering kami via WhatsApp.',
                ),
                const SizedBox(height: 20),
                DemoPrimaryButton(
                  label: 'Chat WhatsApp Admin',
                  icon: Icons.chat,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    AdminWhatsappService.open(
                      purpose: AdminWhatsappPurpose.other,
                      name: 'Humiiu',
                      kelas: 'XII IPS 2',
                      details: 'Halo admin, saya butuh bantuan terkait katering',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdminSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                  style: AppText.sectionTitle.copyWith(fontSize: 22),
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

// ============================================================================
// Data model for menu items
// ============================================================================
class HomeMenuItem {
  final String dayLabel;
  final String title;
  final String subtitle;
  final String? image;

  const HomeMenuItem({
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    this.image,
  });
}

const List<HomeMenuItem> _kMenus = [
  HomeMenuItem(
    dayLabel: 'Senin, 27 Okt',
    title: 'Ayam Telor Asin',
    subtitle: 'lorem',
  ),
  HomeMenuItem(
    dayLabel: 'Selasa, 28 Okt',
    title: 'Mie Chili Oil',
    subtitle: 'lorem',
  ),
  HomeMenuItem(
    dayLabel: 'Rabu, 29 Okt',
    title: 'Ayam Hot Lava',
    subtitle: 'Tahu krispi, timun',
  ),
  HomeMenuItem(
    dayLabel: 'Kamis, 30 Okt',
    title: 'Ayam Teriyaki',
    subtitle: 'Nasi, sayuran, wijen',
  ),
  HomeMenuItem(
    dayLabel: 'Jumat, 31 Okt',
    title: 'Nasi Goreng Spesial',
    subtitle: 'Telur, ayam suwir, kerupuk',
  ),
];

// ============================================================================
// Helper classes
// ============================================================================

class _AdminSheetOption {
  final String title;
  final VoidCallback onTap;

  const _AdminSheetOption({
    required this.title,
    required this.onTap,
  });
}

// ---------------------------------------------------------------------------
// Debt Card (Sisa Tagihan / Hutang)
// Presisi: Soft radial glow, Pill status, Playfair Display amount,
// serta full-width Maroon gradient button dengan shadow glow.
// ---------------------------------------------------------------------------
class _DebtCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DebtCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F261900), // Soft ink shadow
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x069E003A), // Subtle maroon tint
            blurRadius: 10,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient soft warm glow at top right (fades out smoothly)
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x40FFDF9E), // Warm golden peach glow
                      Color(0x18FFDF9E),
                      Color(0x00FFDF9E),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Very subtle cool/tint glow at bottom left
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x0FFFF2E0),
                      Color(0x00FFF2E0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primary,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DEBT LEFT',
                        style: AppText.label.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color(0xFF594043),
                        ),
                      ),
                      const Spacer(),
                      // Status pill indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEADF),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Amount display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp',
                        style: AppText.currency.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF594043),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '60.000',
                        style: AppText.amount.copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: const Color(0xFF261900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Full-width Pay Now Button with Maroon Gradient & Glow
                  _CardActionButton(
                    label: 'Pay Now',
                    icon: Icons.arrow_forward_rounded,
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

// ---------------------------------------------------------------------------
// Card Action Button (inside Debt Card)
// Gradient Maroon + Vibrant glow shadow + Full width
// ---------------------------------------------------------------------------
class _CardActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x409E003A), // Maroon glow shadow
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppText.sectionTitle),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: AppText.link.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Menu Carousel
// ---------------------------------------------------------------------------
class _MenuCarousel extends StatelessWidget {
  final PageController controller;
  final List<HomeMenuItem> menus;

  const _MenuCarousel({required this.controller, required this.menus});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: PageView.builder(
        controller: controller,
        padEnds: false,
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final item = menus[index];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _MenuCard(item: item),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu Card
// Presisi: Warm peach gradient header fading to white,
// White day chip dengan subtle shadow, crisp typography & soft card shadow.
// ---------------------------------------------------------------------------
class _MenuCard extends StatelessWidget {
  final HomeMenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D261900), // Ultra-soft subtle shadow
            blurRadius: 18,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Preview Area with warm peach gradient
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFE0A8), // Warm golden peach
                          Color(0xFFFFE9C7),
                          Colors.white,
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _DayChip(label: item.dayLabel),
                  ),
                ],
              ),
            ),
            // Bottom Information Area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF261900),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF755B5E),
                      height: 1.3,
                    ),
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

// ---------------------------------------------------------------------------
// Day Chip
// White translucent rounded pill with subtle shadow and maroon text
// ---------------------------------------------------------------------------
class _DayChip extends StatelessWidget {
  final String label;

  const _DayChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEBFFFFFF), // White ~92%
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Request Card
// Warm secondaryContainer, pinkish blob corners, tilted star tile,
// and crisp white outlined pill button.
// ---------------------------------------------------------------------------
class _RequestCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RequestCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DD), // Warm soft cream
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08261900),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top right decorative corner blob
            Positioned(
              right: -10,
              top: -10,
              child: _Blob(size: 88, roundBottomLeft: true),
            ),
            // Bottom left decorative corner blob
            Positioned(
              left: -8,
              bottom: -8,
              child: _Blob(size: 72, roundTopRight: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: -0.108, // ~ -6.2 degrees
                    child: _StarTile(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Punya request khusus?',
                    textAlign: TextAlign.center,
                    style: AppText.sectionTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF261900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: const Text(
                      'Beri tahu kami jika ada alergi atau saran makanan untuk pesanan Anda berikutnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B5154),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _OutlinedPill(
                    label: 'Atur Preferensi',
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

// ---------------------------------------------------------------------------
// Blob decorative shape
// ---------------------------------------------------------------------------
class _Blob extends StatelessWidget {
  final double size;
  final bool roundBottomLeft;
  final bool roundTopRight;

  const _Blob({
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
        color: const Color(0xFFF7DED5), // Dusty soft rose peach
        borderRadius: BorderRadius.only(
          bottomLeft: roundBottomLeft ? Radius.circular(size) : Radius.zero,
          topRight: roundTopRight ? Radius.circular(size) : Radius.zero,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Star Tile (58x58, radius 18, golden glow shadow & amber star icon)
// ---------------------------------------------------------------------------
class _StarTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDEA5), // Golden warm peach container
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33735C00), // Warm gold shadow
            blurRadius: 14,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.star_border_rounded,
          color: Color(0xFF735C00),
          size: 30,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Primary Button (Pesan Ketring / Start Buying!)
// Rich Maroon Gradient + Dynamic Box Shadow + 14px rounded corners
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D9E003A), // 30% Maroon shadow glow
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outlined Pill Button (Atur Preferensi)
// Clean white background, delicate border, subtle elevation
// ---------------------------------------------------------------------------
class _OutlinedPill extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlinedPill({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x269E003A), // 15% Maroon outline
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpInfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDEA5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
