// lib/ui/home_page.dart
//
// Halaman Home (customer) Dian Catering, dibangun dari home.png.
// Frame desain: 440 dp lebar. Semua warna/radius/shadow/font dari lib/core/theme.dart.
// Angka layout khusus halaman ini dikumpulkan di class _M (satu tempat untuk dikoreksi).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

// ---------------------------------------------------------------------------
// Metrik layout halaman ini (dp). [terukur] kecuali diberi tanda lain.
// ---------------------------------------------------------------------------
class _M {
  _M._();

  // Header
  static const double headerContent = 53; // di bawah status bar; total ±77 dp
  static const double avatarSize = 32;
  static const double avatarRight = 28;
  static const double avatarLift = 6; // avatar sedikit naik dari tengah

  // Jarak vertikal antar blok [±3 dp, cek di emulator]
  static const double headerToWelcome = 12;
  static const double welcomeToGreeting = 8;
  static const double greetingToDebt = 26;
  static const double debtToSection = 30;
  static const double sectionToMenu = 26;
  static const double menuToRequest = 53;
  static const double requestToCta = 42;
  static const double contentBottom = 13; // + padding atas nav 12 = 25 dp (CTA -> nav)

  // Kartu debt
  static const double debtPad = 24;
  static const double debtRowHeight = 20;
  static const double debtIcon = 20;
  static const double debtRowToAmount = 16;
  static const double amountToButton = 18;
  static const double currencyGap = 8;
  static const double pillWidth = 32;
  static const double pillHeight = 20;
  static const double pillDot = 8;
  static const double payButtonHeight = 52;
  static const double payArrowGap = 8;
  static const double payArrowIcon = 20;

  // Weekly Menu
  static const double chevron = 16;
  static const double menuCardWidth = 238;
  static const double menuCardHeight = 216;
  static const double menuCardGap = 16;
  static const double menuImageHeight = 130;
  static const double menuImageSolidStop = 0.67; // bagian solid sebelum fade ke putih
  static const double menuInset = 16; // padding teks di body kartu
  static const double menuBodyTop = 7;
  static const double menuTitleToSub = 4;
  static const double chipInset = 12;
  static const double chipPadH = 12;
  static const double chipPadV = 8;

  // Kartu "Punya request khusus?"
  static const double requestPad = 32;
  static const double blobTop = 80; // blob kanan atas
  static const double blobBottom = 64; // blob kiri bawah
  static const double tileSize = 64;
  static const double tileIcon = 30;
  static const double tileTiltDeg = -6; // [perkiraan] tile terlihat miring; set 0 kalau lurus
  static const double tileToTitle = 18;
  static const double titleToBody = 8;
  static const double bodyToButton = 24;
  static const double bodyMaxWidth = 220; // supaya pecah baris sama dengan desain
  static const double prefButtonHeight = 42;
  static const double prefButtonPadH = 24;

  // CTA
  static const double ctaInset = 8; // tambahan dari margin halaman -> total 28
  static const double ctaHeight = 52;

  // Bottom nav
  static const double navHeight = 64;
  static const double navMargin = 24;
  static const double navIcon = 22;
  static const double navIconToLabel = 2;
  static const double navBottomMin = 16;
}

// ---------------------------------------------------------------------------
// Model sederhana untuk kartu menu
// ---------------------------------------------------------------------------
class HomeMenuItem {
  const HomeMenuItem({
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    this.image,
  });

  final String dayLabel;
  final String title;
  final String subtitle;

  /// Opsional: widget gambar (mis. Image.network). Kalau null, tampil warna tertiaryContainer.
  final Widget? image;
}

// ---------------------------------------------------------------------------
// HomePage
// ---------------------------------------------------------------------------
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.userName = 'Humiiu',
    this.debtLeft = 60000,
    this.menus = _sampleMenus,
    this.currentNavIndex = 0,
    this.onProfile,
    this.onPayNow,
    this.onSeeAll,
    this.onPreferences,
    this.onStartBuying,
    this.onNavTap,
  });

  final String userName;
  final int debtLeft; // rupiah, tanpa desimal
  final List<HomeMenuItem> menus;
  final int currentNavIndex;

  final VoidCallback? onProfile;
  final VoidCallback? onPayNow;
  final VoidCallback? onSeeAll;
  final VoidCallback? onPreferences;
  final VoidCallback? onStartBuying;
  final ValueChanged<int>? onNavTap;

  static const List<HomeMenuItem> _sampleMenus = [
    HomeMenuItem(dayLabel: 'Senin, 27 Okt', title: 'Ayam Telor Asin', subtitle: 'lorem'),
    HomeMenuItem(dayLabel: 'Selasa, 28 Okt', title: 'Mie Chili Oil', subtitle: 'lorem'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _HomeHeader(onProfile: onProfile),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: _M.contentBottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _M.headerToWelcome),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WELCOME', style: AppText.overline),
                        const SizedBox(height: _M.welcomeToGreeting),
                        Text('Hellow, $userName!', style: AppText.greeting),
                        const SizedBox(height: _M.greetingToDebt),
                        _DebtCard(amount: debtLeft, onPayNow: onPayNow),
                        const SizedBox(height: _M.debtToSection),
                        _SectionHeader(title: 'Weekly Menu', onSeeAll: onSeeAll),
                      ],
                    ),
                  ),
                  const SizedBox(height: _M.sectionToMenu),
                  _MenuList(menus: menus),
                  const SizedBox(height: _M.menuToRequest),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                    child: _RequestCard(onPreferences: onPreferences),
                  ),
                  const SizedBox(height: _M.requestToCta),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.xl + _M.ctaInset,
                    ),
                    child: _PrimaryButton(
                      label: 'Start Buying!',
                      height: _M.ctaHeight,
                      radius: AppRadius.buttonLg,
                      shadows: AppShadows.ctaButton,
                      style: AppText.buttonLg,
                      onTap: onStartBuying,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _HomeBottomNav(
        currentIndex: currentNavIndex,
        onTap: onNavTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.onProfile});

  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      height: top + _M.headerContent,
      padding: EdgeInsets.only(
        top: top,
        right: _M.avatarRight,
        bottom: _M.avatarLift,
      ),
      alignment: Alignment.centerRight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bar,
      ),
      child: InkResponse(
        onTap: onProfile,
        child: const Icon(
          Icons.account_circle_outlined,
          size: _M.avatarSize,
          color: AppColors.avatarIcon,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu "DEBT LEFT"
// ---------------------------------------------------------------------------
class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.amount, this.onPayNow});

  final int amount;
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        children: [
          // Glow kanan atas
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.6),
                  radius: 0.4,
                  colors: [AppColors.glowWarm, AppColors.transparent],
                ),
              ),
            ),
          ),
          // Glow kiri bawah
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, 1.0),
                  radius: 0.4,
                  colors: [AppColors.glowCool, AppColors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_M.debtPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _M.debtRowHeight,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: _M.debtIcon,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: AppSpace.xs),
                      Text('DEBT LEFT', style: AppText.label),
                      const Spacer(),
                      const _StatusPill(),
                    ],
                  ),
                ),
                const SizedBox(height: _M.debtRowToAmount),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Rp', style: AppText.currency),
                    const SizedBox(width: _M.currencyGap),
                    Text(_formatRupiah(amount), style: AppText.amount),
                  ],
                ),
                const SizedBox(height: _M.amountToButton),
                _PrimaryButton(
                  label: 'Pay Now',
                  height: _M.payButtonHeight,
                  radius: AppRadius.buttonSm,
                  shadows: AppShadows.payButton,
                  style: AppText.buttonSm,
                  trailing: const Icon(
                    Icons.arrow_forward,
                    size: _M.payArrowIcon,
                    color: AppColors.onPrimary,
                  ),
                  trailingGap: _M.payArrowGap,
                  onTap: onPayNow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _M.pillWidth,
      height: _M.pillHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.pillBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Container(
        width: _M.pillDot,
        height: _M.pillDot,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tombol utama (Pay Now, Start Buying!)
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.shadows,
    required this.style,
    this.trailing,
    this.trailingGap = 0,
    this.onTap,
  });

  final String label;
  final double height;
  final double radius;
  final List<BoxShadow> shadows;
  final TextStyle style;
  final Widget? trailing;
  final double trailingGap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: style),
                if (trailing != null) ...[
                  SizedBox(width: trailingGap),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header section "Weekly Menu  See All >"
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppText.sectionTitle),
        const Spacer(),
        InkResponse(
          onTap: onSeeAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See All', style: AppText.link),
              const Icon(
                Icons.chevron_right,
                size: _M.chevron,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Daftar menu horizontal
// ---------------------------------------------------------------------------
class _MenuList extends StatelessWidget {
  const _MenuList({required this.menus});

  final List<HomeMenuItem> menus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // tinggi kartu + ruang untuk shadow di bawah
      height: _M.menuCardHeight + AppSpace.lg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
        itemCount: menus.length,
        separatorBuilder: (_, __) => const SizedBox(width: _M.menuCardGap),
        itemBuilder: (context, i) => Align(
          alignment: Alignment.topLeft,
          child: _MenuCard(item: menus[i]),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item});

  final HomeMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _M.menuCardWidth,
      height: _M.menuCardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.menuCard),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _M.menuImageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.image != null) item.image!,
                // Warna dasar + fade ke putih di bagian bawah
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.tertiaryContainer,
                        AppColors.tertiaryContainer,
                        AppColors.card,
                      ],
                      stops: [0, _M.menuImageSolidStop, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: _M.chipInset,
                  top: _M.chipInset,
                  child: _DayChip(label: item.dayLabel),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _M.menuInset,
              _M.menuBodyTop,
              _M.menuInset,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppText.menuTitle),
                const SizedBox(height: _M.menuTitleToSub),
                Text(item.subtitle, style: AppText.menuSub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _M.chipPadH,
        vertical: _M.chipPadV,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppText.chip),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu "Punya request khusus?"
// ---------------------------------------------------------------------------
class _RequestCard extends StatelessWidget {
  const _RequestCard({this.onPreferences});

  final VoidCallback? onPreferences;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: double.infinity,
        color: AppColors.secondaryContainer,
        child: Stack(
          children: [
            // Blob kanan atas (sudut kiri bawahnya melengkung penuh)
            const Positioned(
              top: 0,
              right: 0,
              child: _Blob(
                size: _M.blobTop,
                radius: BorderRadius.only(bottomLeft: Radius.circular(_M.blobTop)),
              ),
            ),
            // Blob kiri bawah (sudut kanan atasnya melengkung penuh)
            const Positioned(
              left: 0,
              bottom: 0,
              child: _Blob(
                size: _M.blobBottom,
                radius: BorderRadius.only(topRight: Radius.circular(_M.blobBottom)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(_M.requestPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _StarTile(),
                  const SizedBox(height: _M.tileToTitle),
                  Text(
                    'Punya request khusus?',
                    textAlign: TextAlign.center,
                    style: AppText.sectionTitle,
                  ),
                  const SizedBox(height: _M.titleToBody),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _M.bodyMaxWidth),
                    child: Text(
                      'Beri tahu kami jika ada alergi atau saran makanan untuk pesanan Anda berikutnya.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                  ),
                  const SizedBox(height: _M.bodyToButton),
                  _OutlinedPill(label: 'Atur Preferensi', onTap: onPreferences),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.radius});

  final double size;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.blob, borderRadius: radius),
    );
  }
}

class _StarTile extends StatelessWidget {
  const _StarTile();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _M.tileTiltDeg * math.pi / 180,
      child: Container(
        width: _M.tileSize,
        height: _M.tileSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.tile),
          boxShadow: AppShadows.tile,
        ),
        child: const Icon(
          Icons.star_border,
          size: _M.tileIcon,
          color: AppColors.tertiary,
        ),
      ),
    );
  }
}

class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.buttonLg);
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: _M.prefButtonHeight,
          padding: const EdgeInsets.symmetric(horizontal: _M.prefButtonPadH),
          child: Center(
            widthFactor: 1,
            child: Text(label, style: AppText.buttonOutlined),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation (Home, Order, History, Profile)
// ---------------------------------------------------------------------------
class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({required this.currentIndex, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const List<_NavItem> _items = [
    _NavItem('Home', Icons.home_outlined),
    _NavItem('Order', Icons.restaurant_menu),
    _NavItem('History', Icons.history),
    _NavItem('Profile', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        _M.navMargin,
        AppSpace.md,
        _M.navMargin,
        math.max(inset, _M.navBottomMin),
      ),
      child: Container(
        height: _M.navHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.nav),
          boxShadow: AppShadows.bar,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: _NavButton(
                  item: _items[i],
                  active: i == currentIndex,
                  onTap: onTap == null ? null : () => onTap!(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, this.onTap});

  final _NavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryDark : AppColors.inkVariant;
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: _M.navIcon, color: color),
          const SizedBox(height: _M.navIconToLabel),
          Text(item.label, style: active ? AppText.navActive : AppText.nav),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Util: 60000 -> "60.000"
// ---------------------------------------------------------------------------
String _formatRupiah(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}