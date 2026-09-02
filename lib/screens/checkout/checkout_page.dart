import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../utils/formatters.dart';
import '../order/order_page.dart';

/// Halaman checkout: ringkasan pesanan + pilih metode bayar.
/// QRIS only untuk Midtrans (1-time QRIS), bank/ewallet placeholder.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> with TickerProviderStateMixin {
  PaymentMethod? _selectedMethod;
  bool _submitting = false;
  late AnimationController _timerController;
  int _qrTimerSeconds = 300; // 5 minutes for QRIS

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // Start timer when QRIS is selected
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _startQrTimer() {
    _qrTimerSeconds = 300;
    _timerController.repeat();
  }

  void _stopQrTimer() {
    _timerController.stop();
  }

  Future<void> _confirm() async {
    final checkoutState = ref.read(checkoutProvider);
    if (_selectedMethod == null || checkoutState == null || checkoutState.items.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final db = ref.read(databaseServiceProvider);
      
      Order? finalOrder;

      if (checkoutState.isPayingExistingDebt) {
        // Mark existing orders as paid
        for (final orderId in checkoutState.existingOrderIds!) {
          await db.markPaid(orderId);
        }
        // In this case, we don't have a "new" Order object for the QRIS sheet directly,
        // but we can create a dummy one or fetch the first one.
        // For simulation, we'll create a summary order.
        finalOrder = Order(
          id: 'payoff',
          userId: ref.read(currentUserIdProvider) ?? '',
          selectedDays: ['Riwayat'],
          menuPerDay: {},
          totalPrice: checkoutState.total,
          isPaid: true, // Will be true after payoff
          paymentMethod: _selectedMethod!,
          createdAt: DateTime.now(),
        );
      } else {
        // Susun data order dari keranjang.
        final cart = checkoutState.items;
        final days = cart.map((c) => c.day).toSet().toList();
        final menuPerDay = <String, List<String>>{};
        for (final item in cart) {
          (menuPerDay[item.day] ??= <String>[]).addAll(List.filled(item.quantity, item.menuId));
        }
        final total = checkoutState.total;
        final now = DateTime.now();

        finalOrder = Order(
          id: '', // Will be assigned by Firebase push()
          userId: ref.read(currentUserIdProvider) ?? '',
          selectedDays: days,
          menuPerDay: menuPerDay,
          totalPrice: total,
          isPaid: false, // Will be updated after payment
          paymentMethod: _selectedMethod!,
          createdAt: now,
          // Due date: Friday of this week
          dueDate: now.add(Duration(days: (DateTime.friday - now.weekday) % 7)),
        );

        await db.createOrder(finalOrder);
      }

      // INVALIDATE: Ensure dashboard and history update
      ref.invalidate(tagihanProvider);
      ref.invalidate(ordersProvider);

      // Clear cart
      ref.read(cartProvider.notifier).state = [];
      ref.read(selectedDaysProvider.notifier).state = {};
      // Clear checkout state
      ref.read(checkoutProvider.notifier).state = null;

      if (!mounted) return;

      if (_selectedMethod == PaymentMethod.qris) {
        _showQrisSheet(context, finalOrder);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkoutState.isPayingExistingDebt 
                  ? 'Tagihan berhasil dibayar' 
                  : 'Pesanan berhasil dibuat', 
                style: AppTextStyles.bodyMedium),
              backgroundColor: AppColors.textPrimary,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e', style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showQrisSheet(BuildContext context, Order order) {
    _startQrTimer();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _QrisPaymentSheet(
        order: order,
        timerSeconds: _qrTimerSeconds,
        onTimerTick: (seconds) => setState(() => _qrTimerSeconds = seconds),
        onClose: () {
          _stopQrTimer();
          Navigator.pop(context);
          if (context.mounted) context.go('/home');
        },
        onPaid: () {
          _stopQrTimer();
          Navigator.pop(context);
          if (context.mounted) context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    
    // Fallback if checkoutState is null (shouldn't happen if flow is correct)
    if (checkoutState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Checkout state empty')),
      );
    }

    final items = checkoutState.items;
    final total = checkoutState.total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.welcome.copyWith(fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => context.go('/order'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Order Summary Card ----
          _OrderSummaryCard(cart: items, total: total),
          const SizedBox(height: 24),

          // ---- Payment Method Selection ----
          Text('Metode Pembayaran', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          ...PaymentMethod.values
              .where((m) => checkoutState.isPayingExistingDebt ? m != PaymentMethod.hutang : true)
              .map((method) => _PaymentMethodCard(
                method: method,
                isSelected: _selectedMethod == method,
                onTap: () {
                  setState(() {
                    _selectedMethod = method;
                  });
                },
              )),
          const SizedBox(height: 24),

          // ---- Confirm Button ----
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: (_selectedMethod == null || _submitting || items.isEmpty) ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.shadowPrimaryButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: AppTextStyles.buttonLarge,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Konfirmasi & Bayar'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final List<CartItem> cart;
  final int total;

  const _OrderSummaryCard({required this.cart, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        shadows: AppShadows.cardElevated,
      ),
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
                  child: Text('1', style: AppTextStyles.button.copyWith(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Text('Ringkasan Pesanan', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 20),
          ...cart.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.menuName} x${item.quantity}', style: AppTextStyles.bodyMediumBold),
                          Text(item.day.capitalize(), style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.rupiah(item.price * item.quantity),
                      style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24, thickness: 1, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary)),
              Text(
                AppFormatters.rupiah(total),
                style: AppTextStyles.priceMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = {
      PaymentMethod.qris: Icons.qr_code_2,
      PaymentMethod.virtualAccount: Icons.account_balance_outlined,
      PaymentMethod.eWallet: Icons.wallet_outlined,
      PaymentMethod.hutang: Icons.schedule_outlined,
    };

    final isPlaceholder = method != PaymentMethod.qris && method != PaymentMethod.hutang;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            shadows: isSelected ? AppShadows.cardElevated : AppShadows.card,
          ),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 16),
              // Method icon
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: isPlaceholder ? AppColors.accent : AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Icon(
                  icons[method] ?? Icons.payment,
                  color: isPlaceholder ? AppColors.textSecondary : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Method info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.label,
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: isPlaceholder ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        if (isPlaceholder) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: ShapeDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                            ),
                            child: Text(
                              'Soon',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: isPlaceholder ? AppColors.textSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrisPaymentSheet extends StatefulWidget {
  final Order order;
  final int timerSeconds;
  final void Function(int) onTimerTick;
  final VoidCallback onClose;
  final VoidCallback onPaid;

  const _QrisPaymentSheet({
    required this.order,
    required this.timerSeconds,
    required this.onTimerTick,
    required this.onClose,
    required this.onPaid,
  });

  @override
  State<_QrisPaymentSheet> createState() => _QrisPaymentSheetState();
}

class _QrisPaymentSheetState extends State<_QrisPaymentSheet> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _timerController;
  int _remainingSeconds = 300;
  bool _isPaid = false;
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = widget.timerSeconds;
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTimerTick);
    _timerController.repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final diff = DateTime.now().difference(_backgroundTime!).inSeconds;
        setState(() {
          _remainingSeconds = (_remainingSeconds - diff).clamp(0, 300);
        });
        widget.onTimerTick(_remainingSeconds);
        if (_remainingSeconds <= 0) {
          _handleTimeout();
        }
      }
    }
  }

  void _onTimerTick() {
    if (_remainingSeconds > 0) {
      setState(() => _remainingSeconds--);
      widget.onTimerTick(_remainingSeconds);
    } else {
      _timerController.stop();
      _handleTimeout();
    }
  }

  void _handleTimeout() {
    if (mounted) {
      _timerController.stop();
      setState(() => _isPaid = false);
      // Show timeout dialog if not already shown
      if (ModalRoute.of(context)?.isCurrent == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Waktu Habis', style: AppTextStyles.sectionTitle),
            content: Text(
              'QRIS telah kedaluwarsa. Silakan buat pesanan baru.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClose();
                },
                child: Text('OK', style: AppTextStyles.button),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: ShapeDecoration(
              color: _remainingSeconds <= 60 ? AppColors.error.withValues(alpha: 0.1) : AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: _remainingSeconds <= 60 ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Waktu tersisa: ${_formatTime(_remainingSeconds)}',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: _remainingSeconds <= 60 ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QR Code placeholder
          Container(
            width: 200,
            height: 200,
            decoration: ShapeDecoration(
              color: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, color: AppColors.primary, size: 80),
                const SizedBox(height: 12),
                Text(
                  'QRIS 1x Pakai',
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan untuk bayar',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Amount
          Text(
            'Total Bayar',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.rupiah(widget.order.totalPrice),
            style: AppTextStyles.priceLarge,
          ),
          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Column(
              children: [
                _InstructionRow('1', 'Buka aplikasi e-Wallet/Banking'),
                _InstructionRow('2', 'Scan QR Code di atas'),
                _InstructionRow('3', 'Konfirmasi pembayaran'),
                _InstructionRow('4', 'Pesanan otomatis terverifikasi'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _remainingSeconds > 0
                      ? () {
                          _timerController.stop();
                          widget.onClose();
                        }
                      : null,
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
                  onPressed: _remainingSeconds > 0
                      ? () {
                          // Simulate payment success
                          setState(() => _isPaid = true);
                          _timerController.stop();
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (!mounted) return;
                            widget.onPaid();
                            // Show snackbar using root navigator
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pembayaran berhasil!', style: AppTextStyles.bodyMedium),
                                  backgroundColor: AppColors.textPrimary,
                                ),
                              );
                            }
                          });
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(_isPaid ? 'Berhasil!' : 'Sudah Bayar', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;
  const _InstructionRow(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: ShapeDecoration(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

// Extension for capitalize
extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}