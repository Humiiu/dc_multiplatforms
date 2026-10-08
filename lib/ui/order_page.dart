import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(demoOrderProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DemoTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                children: [
                  Text(
                    'Your Order',
                    style: AppTextStyles.welcome.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atur pesanan sesuai yang kamu mau',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _NumberedTitle(number: '1', title: 'Select Days'),
                  const SizedBox(height: 16),
                  ...demoDays.map(
                    (day) => _DayCard(
                      day: day,
                      selected: order.selectedDays.contains(day.key),
                      onTap: () =>
                          ref.read(demoOrderProvider).toggleDay(day.key),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _NumberedTitle(number: '2', title: 'Order Summary'),
                  const SizedBox(height: 16),
                  _OrderSummary(order: order),
                  const SizedBox(height: 24),
                  _NumberedTitle(number: '3', title: 'Payment Method'),
                  const SizedBox(height: 16),
                  _PaymentChoice(
                    selected: order.paymentMethod == DemoPaymentMethod.qris,
                    title: 'Bayar Sekarang',
                    subtitle:
                        'Pay securely online via e-Wallet or Bank Transfer.',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => ref.read(demoOrderProvider).selectPayment(
                          DemoPaymentMethod.qris,
                        ),
                  ),
                  _PaymentChoice(
                    selected: order.paymentMethod == DemoPaymentMethod.payLater,
                    title: 'Bayar Nanti (Ngutang)',
                    subtitle: 'Jatuh tempo akhir minggu ini.',
                    icon: Icons.access_time,
                    onTap: () => ref.read(demoOrderProvider).selectPayment(
                          DemoPaymentMethod.payLater,
                        ),
                  ),
                  const SizedBox(height: 20),
                  DemoPrimaryButton(
                    label: 'Konfirmasi Pesanan',
                    onPressed: order.selectedDays.isEmpty
                        ? null
                        : () => context.push('/checkout'),
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

class _NumberedTitle extends StatelessWidget {
  final String number;
  final String title;

  const _NumberedTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(number, style: AppTextStyles.button),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DemoDay day;
  final bool selected;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9ECEB) : AppColors.accent,
          border: Border.all(
            color: selected ? AppColors.borderStrong : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? AppColors.primary : AppColors.border,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            Text(day.name, style: AppTextStyles.bodyMediumBold),
                      ),
                      Text(
                        'Rp 20.000',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(day.menu, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final DemoOrderState order;

  const _OrderSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          if (order.selectedDayDetails.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Pilih hari untuk melihat ringkasan.',
                style: AppTextStyles.bodySmall,
              ),
            )
          else
            ...order.selectedDayDetails.map(
              (day) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(day.name, style: AppTextStyles.bodyMedium)),
                    Text('Rp 20.000', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          const Divider(color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Tagihan',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
              ),
              Text(
                demoRupiah(order.total),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentChoice({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9ECEB) : AppColors.accent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.borderStrong : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
