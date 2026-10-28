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
                padding: const EdgeInsets.fromLTRB(48, 20, 48, 24),
                children: [
                  Text(
                    'Your Order',
                    style: AppTextStyles.welcome.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 280,
                    child: Text(
                      'Atur pesanan sesuai yang kamu mau',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                          ref.read(demoOrderProvider.notifier).toggleDay(day.key),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _NumberedTitle(number: '2', title: 'Order Summary'),
                  const SizedBox(height: 16),
                  _OrderSummary(order: order),
                  const SizedBox(height: 32),
                  _NumberedTitle(number: '3', title: 'Payment Method'),
                  const SizedBox(height: 16),
                  _PaymentChoice(
                    selected: order.paymentMethod == DemoPaymentMethod.qris,
                    title: 'Pay Now',
                    subtitle:
                        'Pay securely online via e-Wallet or Bank Transfer.',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => ref
                        .read(demoOrderProvider.notifier)
                        .selectPayment(
                          DemoPaymentMethod.qris,
                        ),
                  ),
                  _PaymentChoice(
                    selected: order.paymentMethod == DemoPaymentMethod.payLater,
                    title: 'Pay Later',
                    subtitle: 'Due at the end of this week.',
                    icon: Icons.access_time,
                    onTap: () => ref
                        .read(demoOrderProvider.notifier)
                        .selectPayment(
                          DemoPaymentMethod.payLater,
                        ),
                  ),
                  const SizedBox(height: 20),
                  DemoPrimaryButton(
                    label: 'Confirm Order',
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
          color: selected ? AppColors.selectedPinkAlt : AppColors.peach,
          border: Border.all(
            color: selected ? AppColors.borderSelected : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFD7C9C7)),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.subtle,
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
              (day) => SizedBox(
                height: 44,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                Text(day.name, style: AppTextStyles.bodyMedium),
                          ),
                          Text('Rp 20.000', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    if (day != order.selectedDayDetails.last)
                      const Divider(
                        height: 1,
                        color: Color(0xFFF5D9A8),
                      ),
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
                    fontSize: 22,
                  ),
                ),
              ),
              Text(
                demoRupiah(order.total),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
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
          color: selected ? AppColors.selectedPink : AppColors.peach,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.borderSelected : Colors.transparent,
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
              color: selected ? AppColors.primary : const Color(0xFF9A8F8F),
            ),
          ],
        ),
      ),
    );
  }
}
