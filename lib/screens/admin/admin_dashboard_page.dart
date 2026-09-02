import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/admin_provider.dart';
import '../../models/order.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';

/// Dashboard admin: ringkasan pendapatan, utang aktif, dan pesanan.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Dashboard', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 4),
            Text(
              'Ringkasan katering hari ini',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            ordersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: 'Gagal memuat data: $e',
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
              data: (orders) {
                final paid = orders.where((o) => o.isPaid).toList();
                final unpaid = orders.where((o) => !o.isPaid).toList();
                final revenue = paid.fold<int>(0, (s, o) => s + o.totalPrice);
                final outstanding =
                    unpaid.fold<int>(0, (s, o) => s + o.totalPrice);
                final today = orders
                    .where((o) =>
                        o.createdAt.year == DateTime.now().year &&
                        o.createdAt.month == DateTime.now().month &&
                        o.createdAt.day == DateTime.now().day)
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stat cards
                    LayoutBuilder(
                      builder: (context, c) {
                        final cardCount = 4;
                        final spacing = 16.0;
                        final width = (c.maxWidth - spacing * (cardCount - 1)) /
                            cardCount;
                        final compact = width < 180;
                        return Row(
                          children: [
                            for (var i = 0; i < cardCount; i++) ...[
                              if (i > 0) const SizedBox(width: 16),
                              _StatCard(
                                width: compact ? null : width,
                                title: _statTitles[i],
                                value: compact
                                    ? _statValues(orders, i, revenue,
                                        outstanding, today)
                                    : _statValues(orders, i, revenue,
                                        outstanding, today),
                                icon: _statIcons[i],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan Terbaru',
                              style: AppTextStyles.bodyMediumBold,
                            ),
                            const SizedBox(height: 12),
                            if (orders.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Belum ada pesanan.',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              )
                            else
                              ...orders
                                  .take(6)
                                  .map((o) => _OrderTile(order: o)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static const _statTitles = [
    'Pendapatan Masuk',
    'Utang Aktif',
    'Total Pesanan',
    'Pesanan Hari Ini',
  ];
  static const _statIcons = [
    Icons.payments_outlined,
    Icons.credit_score_outlined,
    Icons.receipt_long_outlined,
    Icons.today_outlined,
  ];

  String _statValues(List<Order> orders, int i, int revenue, int outstanding,
      int today) {
    switch (i) {
      case 0:
        return AppFormatters.rupiah(revenue);
      case 1:
        return AppFormatters.rupiah(outstanding);
      case 2:
        return '${orders.length}';
      default:
        return '$today';
    }
  }
}

class _StatCard extends StatelessWidget {
  final double? width;
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    this.width,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.priceMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final paid = order.isPaid;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: paid
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.2),
        child: Icon(
          paid ? Icons.check_circle : Icons.schedule,
          color: paid ? AppColors.success : AppColors.warning,
        ),
      ),
      title: Text(
        order.selectedDays.join(', '),
        style: AppTextStyles.bodyMediumBold,
      ),
      subtitle: Text(
        '${order.paymentMethod.name} · ${order.weekLabel}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: Text(
        AppFormatters.rupiah(order.totalPrice),
        style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
      ),
    );
  }
}
