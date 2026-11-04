import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../services/admin_whatsapp_service.dart';
import '../services/auth_service.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int _filter = 0;

  DemoHistoryOrder _orderToDemoHistory(Order o) {
    return DemoHistoryOrder(
      week: o.week.isNotEmpty ? o.week : o.weekLabel,
      date: o.date.isNotEmpty
          ? o.date
          : '${o.createdAt.day} ${_monthName(o.createdAt.month)} ${o.createdAt.year} • ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')} WIB',
      days: o.days.isNotEmpty ? o.days : const ['Menu Katering'],
      payment: o.payment.isNotEmpty ? o.payment : (o.isPaid ? 'QRIS' : 'Pay Later'),
      amount: o.amount,
      isPaid: o.isPaid,
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return names[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).value;
    final realOrdersAsync = ref.watch(userOrdersStreamProvider);
    final demoOrders = ref.watch(demoOrderProvider).orders;
    final userProfile = ref.watch(currentUserProfileProvider).value;

    final List<DemoHistoryOrder> allOrders;
    final bool isDemo;

    if (authUser != null && realOrdersAsync.hasValue) {
      final realList = realOrdersAsync.value ?? [];
      if (realList.isNotEmpty) {
        allOrders = realList.map(_orderToDemoHistory).toList();
        isDemo = false;
      } else {
        allOrders = const [];
        isDemo = false;
      }
    } else {
      allOrders = demoOrders;
      isDemo = true;
    }

    final orders = allOrders
        .where((order) =>
            _filter == 0 ||
            (_filter == 1 && order.isPaid) ||
            (_filter == 2 && !order.isPaid))
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(userOrdersStreamProvider);
            ref.invalidate(currentUserProfileProvider);
            ref.invalidate(userDebtStreamProvider);
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const DemoTopBar(),
              const SizedBox(height: 8),
              Text(
                'History',
                style: AppTextStyles.welcome,
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau riwayat pesanan dan status pembayaran',
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
                      final name = userProfile?.name ?? 'Humiiu';
                      final kelas = userProfile?.kelas.label ?? 'XII IPS 2';
                      AdminWhatsappService.open(
                        purpose: AdminWhatsappPurpose.debtPayment,
                        name: name,
                        kelas: kelas,
                        total: order.amount,
                        periode: order.week,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              if (isDemo)
                Text(
                  'Data riwayat ini hanya contoh untuk tampilan demo.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
            ],
          ),
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
    const labels = ['All', 'Paid', 'Unpaid'];

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(i),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == i
                      ? AppColors.primary
                      : AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labels[i],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected == i
                        ? Colors.white
                        : AppColors.inkVariant,
                    height: 1.2,
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
                          : Icons.access_time,
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
              const SizedBox(height: 8),
              for (final day in order.days) ...[
                _HistoryDetailRow(
                  icon: Icons.restaurant,
                  text: day,
                ),
                const SizedBox(height: 6),
              ],
              _HistoryDetailRow(
                icon: Icons.payments_outlined,
                text: order.payment,
                amount: demoRupiah(order.amount),
                amountColor:
                    order.isPaid ? AppColors.textPrimary : AppColors.error,
              ),
              if (!order.isPaid) ...[
                const SizedBox(height: 8),
                DemoPrimaryButton(
                  label: 'Pay Now',
                  icon: Icons.arrow_forward_rounded,
                  height: 38,
                  fontSize: 13.5,
                  borderRadius: 8,
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
        borderRadius: BorderRadius.circular(10),
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
