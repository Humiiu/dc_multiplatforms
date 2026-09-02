import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/admin_provider.dart';
import '../../services/database_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';

/// Admin: daftar semua pesanan + status pembayaran (Bayar/Tunda).
class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String _statusFilter = 'semua'; // semua | lunas | hutang

  Future<void> _togglePaid(Order order) async {
    try {
      await ref
          .read(databaseServiceProvider)
          .updateOrderPaidStatus(order.id, !order.isPaid);
      ref.invalidate(adminOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(order.isPaid
                ? 'Pesanan ditandai sebagai hutang'
                : 'Pesanan ditandai lunas'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pesanan', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 4),
              Text(
                'Kelola status pembayaran setiap pesanan',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              // Filter chips
              Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    selected: _statusFilter == 'semua',
                    onTap: () => setState(() => _statusFilter = 'semua'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Lunas',
                    selected: _statusFilter == 'lunas',
                    onTap: () => setState(() => _statusFilter = 'lunas'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Hutang',
                    selected: _statusFilter == 'hutang',
                    onTap: () => setState(() => _statusFilter = 'hutang'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => AppErrorWidget(
                    message: 'Gagal memuat pesanan: $e',
                    onRetry: () => ref.invalidate(adminOrdersProvider),
                  ),
                  data: (orders) {
                    var filtered = List<Order>.from(orders);
                    if (_statusFilter == 'lunas') {
                      filtered = filtered.where((o) => o.isPaid).toList();
                    } else if (_statusFilter == 'hutang') {
                      filtered = filtered.where((o) => !o.isPaid).toList();
                    }
                    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada pesanan.',
                          style: AppTextStyles.bodySmall,
                        ),
                      );
                    }

                    final isWide = MediaQuery.of(context).size.width >= 700;
                    if (isWide) {
                      return _OrdersTable(
                        orders: filtered,
                        onToggle: _togglePaid,
                      );
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderCard(
                        order: filtered[i],
                        onToggle: _togglePaid,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final void Function(Order) onToggle;

  const _OrderCard({
    required this.order,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(isPaid: order.isPaid),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.selectedDays.join(', '),
                          style: AppTextStyles.bodyMediumBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppFormatters.date(order.createdAt)} · ${order.paymentMethod.name}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.rupiah(order.totalPrice),
                    style: AppTextStyles.priceMedium.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: order.isPaid ? 'Tandai hutang' : 'Tandai lunas',
              icon: Icon(
                order.isPaid ? Icons.undo : Icons.check_circle_outline,
                color: order.isPaid ? AppColors.warning : AppColors.success,
              ),
              onPressed: () => onToggle(order),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTable extends StatelessWidget {
  final List<Order> orders;
  final void Function(Order) onToggle;

  const _OrdersTable({
    required this.orders,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Hari')),
            DataColumn(label: Text('Metode')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final o in orders)
              DataRow(
                cells: [
                  DataCell(Text(AppFormatters.date(o.createdAt))),
                  DataCell(Text(o.selectedDays.join(', '))),
                  DataCell(Text(o.paymentMethod.name)),
                  DataCell(Text(
                    AppFormatters.rupiah(o.totalPrice),
                    style: AppTextStyles.bodyMediumBold,
                  )),
                  DataCell(_StatusBadge(isPaid: o.isPaid)),
                  DataCell(
                    TextButton(
                      onPressed: () => onToggle(o),
                      child: Text(o.isPaid ? 'Tandai hutang' : 'Tandai lunas'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;

  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        isPaid ? 'Lunas' : 'Hutang',
        style: AppTextStyles.labelSmall.copyWith(
          color: isPaid ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
