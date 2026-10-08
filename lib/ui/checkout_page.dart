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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF1D9), Color(0xFFFFE8DC)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL BILL',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          demoRupiah(order.total),
                          style: AppTextStyles.priceLarge.copyWith(
                            color: AppColors.primary,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 46),
                  Text('Payment Method', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 18),
                  _CheckoutMethodCard(
                    title: 'QRIS',
                    detail:
                        'Scan QR code dengan aplikasi e-wallet atau m-banking pilihanmu.',
                    selected: order.paymentMethod == DemoPaymentMethod.qris ||
                        order.paymentMethod == DemoPaymentMethod.payLater,
                    icon: Icons.qr_code_2,
                    onTap: () => ref.read(demoOrderProvider).selectPayment(
                          DemoPaymentMethod.qris,
                        ),
                  ),
                  _CheckoutMethodCard(
                    title: 'Virtual Account',
                    detail:
                        'Transfer melalui ATM, Internet Banking, atau Mobile Banking.',
                    selected:
                        order.paymentMethod == DemoPaymentMethod.virtualAccount,
                    icon: Icons.account_balance_outlined,
                    banks: const ['BCA', 'MDR'],
                    onTap: () => ref.read(demoOrderProvider).selectPayment(
                          DemoPaymentMethod.virtualAccount,
                        ),
                  ),
                  _CheckoutMethodCard(
                    title: 'E-Wallet',
                    detail: 'GoPay, OVO, ShopeePay, Dana, LinkAja.',
                    selected: order.paymentMethod == DemoPaymentMethod.eWallet,
                    icon: Icons.wallet_outlined,
                    banks: const ['G', 'O', 'S'],
                    onTap: () => ref.read(demoOrderProvider).selectPayment(
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
                          'Total Tagihan',
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
                    label: 'Bayar Sekarang',
                    icon: Icons.lock,
                    onPressed: order.total == 0
                        ? null
                        : () {
                            final wasDebtPayment = order.payingExistingDebt;
                            order.addDemoOrder();
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
                  const SizedBox(height: 8),
                  Text(
                    'Demo lokal • tidak memproses pembayaran',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9ECEB) : AppColors.accent,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: selected ? 1.5 : 1,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: bank == 'G'
                            ? const Color(0xFF00AED6)
                            : bank == 'O'
                                ? const Color(0xFF4F35A8)
                                : bank == 'S'
                                    ? const Color(0xFFF44336)
                                    : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        bank,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: bank.length == 1
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 27,
                  ),
                  const SizedBox(width: 10),
                ],
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(detail, style: AppTextStyles.bodySmall),
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
