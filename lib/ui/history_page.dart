import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../services/admin_whatsapp_service.dart';
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
                  Text(
                    'History',
                    style: AppTextStyles.welcome.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'hhhhhhhhhhhhhhistory',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HistoryFilters(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 16),
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
                          // TODO(backend): replace mock debt confirmation flow with real payment backend.
                          AdminWhatsappService.open(
                            purpose: AdminWhatsappPurpose.debtPayment,
                            name: 'Humiiu',
                            kelas: 'XII IPS 2',
                            total: order.amount,
                            periode: order.week,
                          );
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
    const flexes = [7, 10, 8];

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            flex: flexes[i],
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i
                        ? AppColors.primary
                        : AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected == i
                          ? Colors.white
                          : AppColors.inkVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.date, style: AppTextStyles.caption),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: order.isPaid
                          ? AppColors.successSoft
                          : AppColors.dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      order.isPaid
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: order.isPaid ? AppColors.success : AppColors.error,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.week,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 10),
              for (final day in order.days) ...[
                _HistoryDetailRow(
                  icon: Icons.restaurant,
                  text: day,
                ),
                const SizedBox(height: 8),
              ],
              _HistoryDetailRow(
                icon: Icons.payments_outlined,
                text: order.payment,
                amount: demoRupiah(order.amount),
                amountColor:
                    order.isPaid ? AppColors.textPrimary : AppColors.error,
              ),
              if (!order.isPaid) ...[
                const SizedBox(height: 10),
                DemoPrimaryButton(
                  label: 'Bayar Sekarang',
                  icon: Icons.arrow_forward,
                  onPressed: onPay,
                ),
              ],
            ],
          ),
        ),
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
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
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
