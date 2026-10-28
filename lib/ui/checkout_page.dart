import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(demoOrderProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const DemoTopBar(title: 'Checkout', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceVariant,
                          AppColors.background,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.xxl),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL BILL',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.priceLarge.copyWith(
                              color: AppColors.primary,
                              fontSize: 40,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Rp ',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                ),
                              ),
                              TextSpan(
                                text: demoRupiah(order.total)
                                    .replaceFirst('Rp ', ''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Payment Method',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
                  const SizedBox(height: 18),
                  _CheckoutMethodCard(
                    title: 'QRIS',
                    detail:
                        'Scan the QR code with your preferred e-wallet or mobile banking app.',
                    selected: order.paymentMethod == DemoPaymentMethod.qris ||
                        order.paymentMethod == DemoPaymentMethod.payLater,
                    icon: Icons.qr_code_2,
                    onTap: () => ref
                        .read(demoOrderProvider.notifier)
                        .selectPayment(
                          DemoPaymentMethod.qris,
                        ),
                  ),
                  _CheckoutMethodCard(
                    title: 'Virtual Account',
                    detail:
                        'Transfer through an ATM, internet banking, or mobile banking.',
                    selected:
                        order.paymentMethod == DemoPaymentMethod.virtualAccount,
                    icon: Icons.account_balance_outlined,
                    banks: const ['BCA', 'MDR'],
                    onTap: () => ref
                        .read(demoOrderProvider.notifier)
                        .selectPayment(
                          DemoPaymentMethod.virtualAccount,
                        ),
                  ),
                  _CheckoutMethodCard(
                    title: 'E-Wallet',
                    detail: 'GoPay, OVO, ShopeePay, Dana, and LinkAja.',
                    selected: order.paymentMethod == DemoPaymentMethod.eWallet,
                    icon: Icons.wallet_outlined,
                    banks: const ['G', 'O', 'S'],
                    onTap: () => ref
                        .read(demoOrderProvider.notifier)
                        .selectPayment(
                          DemoPaymentMethod.eWallet,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: AppShadows.cardElevated,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Bill',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        demoRupiah(order.total),
                        style: AppTextStyles.bodyMediumBold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DemoPrimaryButton(
                    label: 'Pay Now',
                    icon: Icons.lock,
                    onPressed: order.total == 0
                        ? null
                        : () {
                            final wasDebtPayment = order.payingExistingDebt;
                            ref
                                .read(demoOrderProvider.notifier)
                                .addDemoOrder();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  wasDebtPayment
                                      ? 'Simulasi pelunasan selesai. Tidak ada pembayaran nyata.'
                                      : 'Pesanan demo dicatat. Pembayaran belum diproses.',
                                ),
                              ),
                            );
                            context.go('/history');
                          },
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

class _CheckoutMethodCard extends StatelessWidget {
  final String title;
  final String detail;
  final bool selected;
  final IconData icon;
  final List<String> banks;
  final VoidCallback onTap;

  const _CheckoutMethodCard({
    required this.title,
    required this.detail,
    required this.selected,
    required this.icon,
    required this.onTap,
    this.banks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedPink : AppColors.peach,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primaryDark : Colors.transparent,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.bodyMediumBold),
                ),
                if (banks.isNotEmpty) ...[
                  ...banks.map(
                    (bank) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: banks.length > 2 ? 24 : null,
                      height: banks.length > 2 ? 24 : null,
                      padding: banks.length > 2
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: banks.length > 2 && bank == 'G'
                            ? const Color(0xFF00AED6)
                            : banks.length > 2 && bank == 'O'
                                ? const Color(0xFF4F35A8)
                                : banks.length > 2 && bank == 'S'
                                    ? const Color(0xFFF44336)
                                    : Colors.white,
                        shape: banks.length > 2
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius:
                            banks.length > 2 ? null : BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          bank,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: banks.length > 2 ? 9 : 8,
                            fontWeight: FontWeight.w700,
                            color: banks.length > 2
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  Container(
                    width: 42,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : AppColors.border,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    detail,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 15),
                  ),
                ),
                if (banks.isNotEmpty) const SizedBox(width: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
