import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/menu.dart';
import '../../services/database_service.dart';

/// State keranjang: hari terpilih -> list menu items.
class CartItem {
  final String day;
  final String menuId;
  final String menuName;
  final int price;

  CartItem({
    required this.day,
    required this.menuId,
    required this.menuName,
    required this.price,
  });

  Map<String, dynamic> toMap() =>
      {'day': day, 'menuId': menuId, 'menuName': menuName, 'price': price};
}

final cartProvider = StateProvider<List<CartItem>>((ref) => []);

/// Provider untuk selected days
final selectedDaysProvider = StateProvider<Set<String>>((ref) => {});

/// Halaman pemesanan: Select Days di atas, menu per hari, total + opsi hutang/bayar.
class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  @override
  void initState() {
    super.initState();
    // Check for pre-selected day from query params
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final uri = GoRouterState.of(context).uri;
    //   final dayParam = uri.queryParameters['day'];
    //   if (dayParam != null && hariKerjaDb.contains(dayParam)) {
    //     ref.read(selectedDaysProvider.notifier).state = {dayParam};
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysProvider);
    final cart = ref.watch(cartProvider);
    final total = cart.fold(0, (sum, item) => sum + item.price);
    final canCheckout = selectedDays.isNotEmpty && cart.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pesan Katering', style: AppTextStyles.welcome.copyWith(fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---- Select Days Section (di paling atas) ----
          _SelectDaysSection(selectedDays: selectedDays),
          const Divider(height: 1, thickness: 0.5, color: AppColors.divider),

          // ---- Menu List for Selected Days ----
          Expanded(
            child: selectedDays.isEmpty
                ? _EmptyState()
                : _MenuListSection(selectedDays: selectedDays),
          ),

          // ---- Bottom Total + Options ----
          _BottomSection(
            selectedDays: selectedDays,
            cart: cart,
            total: total,
            canCheckout: canCheckout,
          ),
        ],
      ),
    );
  }
}

class _SelectDaysSection extends ConsumerWidget {
  final Set<String> selectedDays;
  const _SelectDaysSection({required this.selectedDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Center(
                  child: Text(
                    '1',
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Pilih Hari', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hariKerjaDb.asMap().entries.map((entry) {
              final index = entry.key;
              final dayKey = entry.value;
              final dayName = hariKerja[index];
              final isSelected = selectedDays.contains(dayKey);

              return _DayChip(
                dayName: dayName,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedDaysProvider.notifier).update((state) {
                    final newSet = Set<String>.from(state);
                    if (isSelected) {
                      newSet.remove(dayKey);
                    } else {
                      newSet.add(dayKey);
                    }
                    return newSet;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String dayName;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.dayName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 0 : 1.5,
              ),
            ),
            shadows: isSelected ? AppShadows.buttonPrimary : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayName,
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuListSection extends ConsumerWidget {
  final Set<String> selectedDays;
  const _MenuListSection({required this.selectedDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedDays = selectedDays.toList()
      ..sort((a, b) => hariKerjaDb.indexOf(a).compareTo(hariKerjaDb.indexOf(b)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: sortedDays.map((dayKey) {
        final dayName = hariKerja[hariKerjaDb.indexOf(dayKey)];
        return _DayMenuSection(dayKey: dayKey, dayName: dayName);
      }).toList(),
    );
  }
}

class _DayMenuSection extends ConsumerWidget {
  final String dayKey;
  final String dayName;
  const _DayMenuSection({required this.dayKey, required this.dayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseServiceProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: db.getMenusForDay(dayKey),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _DayMenuSkeleton(dayName: dayName);
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return _EmptyDaySection(dayName: dayName);
        }
        final menus = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayName[0],
                        style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(dayName, style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                    ),
                    child: Text(
                      '${menus.length} menu',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final key = menus.keys.elementAt(index);
                final data = menus[key] as Map<dynamic, dynamic>;
                final menu = MenuItem.fromMap(key, data);
                final isInCart = ref.watch(cartProvider).any(
                  (item) => item.day == dayKey && item.menuId == menu.id,
                );

                return _MenuItemCard(
                  menu: menu,
                  isInCart: isInCart,
                  onTap: () {
                    if (isInCart) {
                      // Remove from cart
                      ref.read(cartProvider.notifier).update((list) =>
                          list.where((item) => !(item.day == dayKey && item.menuId == menu.id)).toList());
                    } else {
                      // Add to cart
                      ref.read(cartProvider.notifier).update((list) => [
                            ...list,
                            CartItem(
                              day: dayKey,
                              menuId: menu.id,
                              menuName: menu.name,
                              price: menu.price,
                            ),
                          ]);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _DayMenuSkeleton extends StatelessWidget {
  final String dayName;
  const _DayMenuSkeleton({required this.dayName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  color: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Center(
                  child: Text(
                    dayName[0],
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(dayName, style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, __) => _MenuItemSkeleton(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _EmptyDaySection extends StatelessWidget {
  final String dayName;
  const _EmptyDaySection({required this.dayName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  color: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Center(
                  child: Text(
                    dayName[0],
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(dayName, style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.restaurant_menu, color: AppColors.textSecondary, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Belum ada menu untuk $dayName',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem menu;
  final bool isInCart;
  final VoidCallback onTap;

  const _MenuItemCard({
    required this.menu,
    required this.isInCart,
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
            color: isInCart ? AppColors.primaryLight : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isInCart ? AppColors.primary : AppColors.border,
                width: isInCart ? 1.5 : 0.5,
              ),
            ),
            shadows: AppShadows.card,
          ),
          child: Row(
            children: [
              // Menu image placeholder
              Container(
                width: 56,
                height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: menu.imageUrl != null
                    ? Image.network(
                        menu.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),
              // Menu info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: AppTextStyles.bodyMediumBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${menu.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              // Add/Remove button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: isInCart ? AppColors.primary : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(
                      color: isInCart ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Icon(
                  isInCart ? Icons.check : Icons.add,
                  color: isInCart ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.restaurant_menu, color: AppColors.primary.withValues(alpha: 0.3), size: 28),
    );
  }
}

class _MenuItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: ShapeDecoration(
              color: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
            ),
            child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 56),
          ),
          const SizedBox(height: 24),
          Text(
            'Pilih hari terlebih dahulu',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih hari di atas untuk melihat menu\nlalu tambahkan ke keranjang',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends ConsumerWidget {
  final Set<String> selectedDays;
  final List<CartItem> cart;
  final int total;
  final bool canCheckout;

  const _BottomSection({
    required this.selectedDays,
    required this.cart,
    required this.total,
    required this.canCheckout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayCount = selectedDays.length;
    final dailyPrice = dayCount > 0 ? total ~/ dayCount : AppConstants.defaultDailyPrice;
    final isOverLimit = total > AppConstants.maxUtang;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 10,
            offset: const Offset(0, -3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dayCount hari dipilih • $dailyPrice/hari',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: AppTextStyles.priceMedium,
                      ),
                    ],
                  ),
                ),
                if (isOverLimit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Melebihi batas',
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment options
            Row(
              children: [
                // Hutang option
                Expanded(
                  child: _PaymentOptionCard(
                    icon: Icons.schedule_outlined,
                    title: 'Hutang',
                    subtitle: 'Jatuh tempo minggu ini\nMaks Rp ${(AppConstants.maxUtang / 1000).toInt()}rb',
                    isEnabled: !isOverLimit,
                    onTap: () => _showHutangBottomSheet(context, ref, total),
                  ),
                ),
                const SizedBox(width: 12),
                // Bayar Sekarang option
                Expanded(
                  child: _PaymentOptionCard(
                    icon: Icons.payment_outlined,
                    title: 'Bayar Sekarang',
                    subtitle: 'Via QRIS / Transfer',
                    isEnabled: canCheckout,
                    isPrimary: true,
                    onTap: () => context.go('/checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHutangBottomSheet(BuildContext context, WidgetRef ref, int total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HutangBottomSheet(total: total),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: ShapeDecoration(
            color: isPrimary ? AppColors.primary : (isEnabled ? Colors.white : AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isPrimary ? AppColors.primary : (isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5)),
                width: isPrimary ? 0 : 1.5,
              ),
            ),
            shadows: isPrimary ? AppShadows.buttonPrimary : (isEnabled ? AppShadows.card : []),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : (isEnabled ? AppColors.accent : AppColors.border.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : (isEnabled ? AppColors.primary : AppColors.textSecondary),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: isPrimary ? Colors.white : (isEnabled ? AppColors.textPrimary : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: isPrimary ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HutangBottomSheet extends ConsumerWidget {
  final int total;
  const _HutangBottomSheet({required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Konfirmasi Hutang', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            'Anda akan berhutang Rp ${_formatPrice(total)}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Ketentuan Hutang', style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                _HutangRule('Jatuh tempo: Minggu ini (Jumat pukul 23:59)'),
                _HutangRule('Maksimal hutang: Rp ${(AppConstants.maxUtang / 1000).toInt()}rb'),
                _HutangRule('Melebihi batas → tidak bisa order baru'),
                _HutangRule('Bayar via QRIS/Transfer di halaman History'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text('Batal', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // TODO: Create order with paymentMethod = hutang
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pesanan hutang dibuat', style: AppTextStyles.bodyMedium),
                        backgroundColor: AppColors.textPrimary,
                      ),
                    );
                    ref.read(cartProvider.notifier).state = [];
                    ref.read(selectedDaysProvider.notifier).state = {};
                    context.go('/home');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text('Konfirmasi Hutang', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

class _HutangRule extends StatelessWidget {
  final String text;
  const _HutangRule(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}