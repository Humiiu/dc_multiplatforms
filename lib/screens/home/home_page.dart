import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../models/menu.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';

/// Provider tagihan aktif user (utang yang belum dibayar).
final tagihanProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return 0;
  final orders = await db.getActiveOrders(uid);
  return orders.fold(0, (sum, o) => o.totalPrice);
});

/// Provider untuk menu mingguan
final weeklyMenuProvider = FutureProvider<Map<String, List<MenuItem>>>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final weeklyData = await db.getWeeklyMenu();
  final result = <String, List<MenuItem>>{};
  for (final day in hariKerjaDb) {
    final dayData = weeklyData[day] as Map<dynamic, dynamic>?;
    if (dayData != null) {
      result[day] = dayData.entries.map((e) {
        final data = e.value as Map<dynamic, dynamic>;
        return MenuItem.fromMap(e.key as String, data);
      }).toList();
    } else {
      result[day] = [];
    }
  }
  return result;
});

Future<void> _openAdminWhatsApp(BuildContext context) async {
  final uri = Uri.parse('https://wa.me/${AppConstants.adminWhatsApp}');
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak bisa membuka WA admin: $uri', style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka WA: $e', style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    }
  }
}

/// Dashboard: header "Dashboard", kartu Tagihan Kamu, menu mingguan Senin–Jumat auto-scroll,
/// Request menu card, Pesan Ketring button.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagihanAsync = ref.watch(tagihanProvider);
    final weeklyMenuAsync = ref.watch(weeklyMenuProvider);
    final user = ref.watch(currentUserProvider);
    final userAsync = user != null ? ref.watch(userDataProvider(user.uid)) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.welcome.copyWith(fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Notification bell
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.primaryDark),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tagihanProvider);
          ref.invalidate(weeklyMenuProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Welcome header - matches Figma exactly ----
              _WelcomeHeader(userAsync: userAsync),
              const SizedBox(height: 24),

              // ---- Kartu Tagihan Kamu - matches Figma exactly ----
              _TagihanCard(tagihanAsync: tagihanAsync),
              const SizedBox(height: 16),

              // ---- Menu Mingguan (Senin–Jumat) - Auto Scroll ----
              Text('Menu Minggu Ini', style: AppTextStyles.sectionTitle.copyWith(fontSize: 24)),
              const SizedBox(height: 12),
              _WeeklyMenuCarousel(weeklyMenuAsync: weeklyMenuAsync),
              const SizedBox(height: 16),

              // ---- Request menu khusus → WA admin ----
              _RequestMenuCard(onTap: () => _openAdminWhatsApp(context)),
              const SizedBox(height: 16),

              // ---- Pesan Ketring button ----
              _PesanKetringButton(onTap: () => context.go('/order')),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  final AsyncValue<AppUser?>? userAsync;
  const _WelcomeHeader({required this.userAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Matches Figma: white card, 24px radius, elevated shadow, decorative corner elements
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        shadows: AppShadows.cardElevated,
      ),
      child: Stack(
        children: [
          // Decorative corner elements matching Figma
          Positioned(
            right: -24,
            top: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: ShapeDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: 129,
            child: Container(
              width: 96,
              height: 96,
              decoration: ShapeDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SELAMAT DATANG - matches Figma: 14px, Plus Jakarta Sans, w600, #594043, letter-spacing 0.7
              Text(
                'SELAMAT DATANG',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.7,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // User name - matches Figma: 28px, Playfair Display, w700, #261900
              userAsync?.when(
                data: (u) => Text(
                  u != null ? 'Halo, ${u.name}!' : 'Halo!',
                  style: AppTextStyles.welcome.copyWith(fontSize: 28),
                ),
                loading: () => Text('Halo!', style: AppTextStyles.welcome.copyWith(fontSize: 28)),
                error: (_, __) => Text('Halo!', style: AppTextStyles.welcome.copyWith(fontSize: 28)),
              ) ?? Text('Halo!', style: AppTextStyles.welcome.copyWith(fontSize: 28)),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper to get user data for welcome header
final userDataProvider = FutureProvider.family<AppUser?, String>((ref, uid) async {
  return ref.read(databaseServiceProvider).getUser(uid);
});

class _TagihanCard extends ConsumerWidget {
  final AsyncValue<int> tagihanAsync;
  const _TagihanCard({required this.tagihanAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tagihanAsync.when(
      data: (total) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowPrimary.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative corner elements matching Figma
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: ShapeDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppRadius.xl),
                      bottomLeft: Radius.circular(64),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: ShapeDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(48),
                      bottomLeft: Radius.circular(AppRadius.xl),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SISA TAGIHAN with red dot badge - matches Figma
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: ShapeDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: ShapeDecoration(
                                    color: AppColors.error, // #BA1A1A
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.round),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SISA TAGIHAN',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Amount - matches Figma: Rp + Playfair Display 48px w700 #261900
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('Rp', style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          Text(
                            total.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]}.',
                            ),
                            style: AppTextStyles.priceLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maks utang Rp ${(AppConstants.maxUtang / 1000).toInt()}rb',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Bayar Sekarang button - matches Figma: primary, radius 8, specific shadow
                FilledButton(
                  onPressed: total > 0
                      ? () => ref.read(goRouterProvider).go('/checkout')
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTextStyles.button,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                    shadowColor: WidgetStateProperty.all(const Color(0x33740028)),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: const Text('Bayar Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowPrimary.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: Text('Gagal memuat tagihan', style: AppTextStyles.bodyMedium),
      ),
    );
  }
}

class _WeeklyMenuCarousel extends ConsumerWidget {
  final AsyncValue<Map<String, List<MenuItem>>> weeklyMenuAsync;
  const _WeeklyMenuCarousel({required this.weeklyMenuAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return weeklyMenuAsync.when(
      data: (weeklyMenu) {
        final daysWithMenu = hariKerjaDb.where((day) => (weeklyMenu[day]?.isNotEmpty ?? false)).toList();

        if (daysWithMenu.isEmpty) {
          return Container(
            height: 250,
            alignment: Alignment.center,
            child: Text(
              'Belum ada menu minggu ini',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: daysWithMenu.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final dayKey = daysWithMenu[index];
              final dayName = hariKerja[hariKerjaDb.indexOf(dayKey)];
              final menus = weeklyMenu[dayKey]!;
              final firstMenu = menus.isNotEmpty ? menus.first : null;

              // Calculate date for this day
              final now = DateTime.now();
              final dayIndex = hariKerjaDb.indexOf(dayKey);
              final currentDayIndex = now.weekday - 1; // Monday = 0
              int daysToAdd = dayIndex - currentDayIndex;
              if (daysToAdd < 0) daysToAdd += 7;
              final targetDate = now.add(Duration(days: daysToAdd));
              final dateStr = '$dayName, ${targetDate.day} ${_monthName(targetDate.month)}';

              return _MenuDayCard(
                dayName: dayName,
                dateStr: dateStr,
                menuCount: menus.length,
                firstMenu: firstMenu,
                onTap: () {
                  context.go('/order?day=$dayKey');
                },
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 250,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => _MenuDayCardSkeleton(),
        ),
      ),
      error: (_, __) => Container(
        height: 250,
        alignment: Alignment.center,
        child: Text('Gagal memuat menu', style: AppTextStyles.bodyMedium),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}

class _MenuDayCard extends StatelessWidget {
  final String dayName;
  final String dateStr;
  final int menuCount;
  final MenuItem? firstMenu;
  final VoidCallback onTap;

  const _MenuDayCard({
    required this.dayName,
    required this.dateStr,
    required this.menuCount,
    this.firstMenu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Matches Figma: 240x218, white, radius 16, elevated shadow
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 240,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            shadows: AppShadows.cardElevated,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with date badge - matches Figma
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 128,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: AppColors.primaryLight),
                    child: firstMenu?.imageUrl != null
                        ? Image.network(
                            firstMenu!.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 128,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Date badge - matches Figma: top-left, white 90% opacity, radius 12, subtle shadow
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        shadows: AppShadows.subtle,
                      ),
                      child: Text(
                        dateStr,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Gradient overlay at bottom of image - matches Figma
              Container(
                width: double.infinity,
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              // Menu info - matches Figma
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstMenu?.name ?? '$menuCount menu tersedia',
                      style: AppTextStyles.bodyMediumBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstMenu != null
                          ? 'Rp ${firstMenu!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
                          : '$menuCount menu tersedia',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (menuCount > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${menuCount - 1} menu lain',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 128,
      color: AppColors.primaryLight,
      child: Center(
        child: Icon(Icons.restaurant_menu, color: AppColors.primary.withValues(alpha: 0.3), size: 48),
      ),
    );
  }
}

class _MenuDayCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        shadows: AppShadows.cardElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 128,
            color: AppColors.primaryLight,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
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

class _RequestMenuCard extends StatelessWidget {
  final VoidCallback onTap;
  const _RequestMenuCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches Figma exactly: cream #FFF2E0 background, radius 32, decorative corners
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.surfaceVariant, // #FFF2E0
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: ShapeDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(64),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: ShapeDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(48),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rotated icon container - matches Figma
                  Transform.rotate(
                    angle: 0.05,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: ShapeDecoration(
                        color: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        shadows: [
                          BoxShadow(
                            color: AppColors.shadowPrimary.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title - matches Figma: Playfair Display 24px w600
                  Text(
                    'Punya Request Khusus?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 8),
                  // Description - matches Figma: centered, 14px #594043
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Beri tahu kami jika ada alergi atau saran makanan untuk pesanan Anda berikutnya.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Atur Preferensi button - matches Figma: white, radius 12, primary text, subtle shadows
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          blurRadius: 0,
                          offset: Offset.zero,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      'Atur Preferensi',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PesanKetringButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PesanKetringButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches Figma: full width-56, height 52, primary, Plus Jakarta Sans 16px w600, strong shadow
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            shadows: AppShadows.buttonPrimaryStrong,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Pesan Ketring',
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});