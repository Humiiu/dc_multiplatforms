import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(demoOrderProvider).orders;
    final orders = allOrders
        .where((order) =>
            _filter == 0 ||
            (_filter == 1 && order.isPaid) ||
            (_filter == 2 && !order.isPaid))
        .toList();
    final total = allOrders.fold<int>(0, (sum, order) => sum + order.amount);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DemoTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.welcome.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 29,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Seluruh Ketring:',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    demoRupiah(total),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _HistoryFilters(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 26),
                  if (orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Text(
                        'Tidak ada pesanan pada filter ini.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  else
                    ...orders.map(
                      (order) => _HistoryCard(
                        order: order,
                        onPay: () {
                          ref.read(demoOrderProvider).prepareDebtPayment(
                                order.amount,
                                targetWeek: order.week,
                              );
                          context.push('/checkout');
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Data riwayat ini hanya contoh untuk tampilan demo.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
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

class _HistoryFilters extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _HistoryFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const labels = ['Semua', 'Sudah Lunas', 'Belum Lunas'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            ChoiceChip(
              label: Text(labels[i]),
              selected: selected == i,
              showCheckmark: false,
              onSelected: (_) => onSelected(i),
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: selected == i ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DemoHistoryOrder order;
  final VoidCallback onPay;

  const _HistoryCard({required this.order, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.date, style: AppTextStyles.caption),
              ),
              Container(
                width: 38,
                height: 23,
                decoration: BoxDecoration(
                  color: order.isPaid
                      ? const Color(0xFFEFFAF3)
                      : const Color(0xFFFFE1DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.isPaid ? Icons.check_circle_outline : Icons.access_time,
                  color: order.isPaid
                      ? const Color(0xFF17843B)
                      : AppColors.primary,
                  size: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(order.week,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 19)),
          const SizedBox(height: 16),
          for (final day in order.days) ...[
            _HistoryDetailRow(
              icon: Icons.restaurant,
              text: day,
            ),
            const SizedBox(height: 7),
          ],
          _HistoryDetailRow(
            icon: Icons.payments_outlined,
            text: order.payment,
            amount: demoRupiah(order.amount),
            amountColor: order.isPaid ? AppColors.textPrimary : AppColors.error,
          ),
          if (!order.isPaid) ...[
            const SizedBox(height: 16),
            DemoPrimaryButton(
              label: 'Bayar Sekarang',
              icon: Icons.arrow_forward,
              onPressed: onPay,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? amount;
  final Color? amountColor;

  const _HistoryDetailRow({
    required this.icon,
    required this.text,
    this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 15),
          const SizedBox(width: 7),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
          if (amount != null)
            Text(
              amount!,
              style: AppTextStyles.bodyMediumBold.copyWith(color: amountColor),
            ),
        ],
      ),
    );
  }
}
