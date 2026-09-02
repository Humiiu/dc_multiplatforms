import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../providers/order_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';

/// Riwayat pesanan, dikelompokkan per minggu dengan status lunas/utang.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Riwayat Pesanan', style: AppTextStyles.welcome.copyWith(fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
        },
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return _EmptyHistoryState();
            }

            // Terbaru dulu, lalu kelompokkan per minggu.
            final sortedOrders = List<Order>.from(orders)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            final grouped = <String, List<Order>>{};
            for (final o in sortedOrders) {
              final weekKey = o.weekLabel;
              (grouped[weekKey] ??= []).add(o);
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                final weekTotal = entry.value.fold(0, (sum, o) => sum + o.totalPrice);
                final hasUnpaid = entry.value.any((o) => !o.isPaid);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Week header with total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
                        Text(
                        'Total: ${AppFormatters.rupiah(weekTotal)}',
                        style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                      ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...entry.value.map((o) => _OrderCard(order: o)),
                    if (hasUnpaid) ...[
                      const SizedBox(height: 12),
                      _PayUnpaidButton(
                        weekKey: entry.key,
                        total: entry.value.where((o) => !o.isPaid).fold(0, (sum, o) => sum + o.totalPrice),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Gagal memuat riwayat: $e',
            onRetry: () => ref.invalidate(ordersProvider),
          ),
        ),
      ),
    );
  }

}

class _EmptyHistoryState extends StatelessWidget {
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
            child: Icon(Icons.history, color: AppColors.primary, size: 56),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada riwayat pesanan',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesan catering pertama Anda\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.restaurant_menu),
            label: Text('Pesan Sekarang', style: AppTextStyles.buttonLarge),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => context.go('/order'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('dd MMM yyyy • HH:mm');
    final dayCount = order.selectedDays.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeFmt.format(order.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: order.isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                  ),
                  child: Text(
                    order.isPaid ? 'Lunas' : 'Hutang',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: order.isPaid ? Colors.green.shade700 : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order details
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: order.paymentMethod == PaymentMethod.hutang
                        ? AppColors.secondary
                        : AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Icon(
                    _getPaymentIcon(order.paymentMethod),
                    color: order.paymentMethod == PaymentMethod.hutang
                        ? AppColors.primary
                        : AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getPaymentLabel(order.paymentMethod)} • $dayCount hari',
                        style: AppTextStyles.bodyMediumBold,
                      ),
                      Text(
                        order.selectedDays.map((d) => d.capitalize()).join(', '),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  AppFormatters.rupiah(order.totalPrice),
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: order.isPaid ? Colors.green.shade700 : AppColors.primary,
                  ),
                ),
              ],
            ),

            // Due date for unpaid orders
            if (!order.isPaid && order.dueDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(order.dueDate!)}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                    if (order.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: ShapeDecoration(
                          color: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                        ),
                        child: Text(
                          'TERLAMBAT',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.qris:
        return Icons.qr_code_2;
      case PaymentMethod.virtualAccount:
        return Icons.account_balance;
      case PaymentMethod.eWallet:
        return Icons.wallet;
      case PaymentMethod.hutang:
        return Icons.schedule;
    }
  }

  String _getPaymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.virtualAccount:
        return 'Virtual Account';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.hutang:
        return 'Hutang';
    }
  }

}

class _PayUnpaidButton extends ConsumerWidget {
  final String weekKey;
  final int total;

  const _PayUnpaidButton({required this.weekKey, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(Icons.payment, color: AppColors.primary),
        label: Text(
          'Bayar Hutang Minggu Ini (${AppFormatters.rupiah(total)})',
          style: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        onPressed: () async {
          final db = ref.read(databaseServiceProvider);
          final uid = ref.read(currentUserIdProvider);
          if (uid == null) return;
          
          final orders = await db.getUserOrders(uid);
          final weekOrders = orders.where((o) => o.weekLabel == weekKey && !o.isPaid).toList();
          
          final checkoutItems = weekOrders.map((o) => CartItem(
            day: o.weekLabel,
            menuId: o.id,
            menuName: 'Tagihan ${o.weekLabel}',
            price: o.totalPrice,
            quantity: 1,
          )).toList();

          ref.read(checkoutProvider.notifier).state = CheckoutState(
            items: checkoutItems,
            total: total,
            existingOrderIds: weekOrders.map((o) => o.id).toList(),
          );
          if (context.mounted) {
            context.go('/checkout');
          }
        },
      ),
    );
  }

}

extension StringExtension on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}