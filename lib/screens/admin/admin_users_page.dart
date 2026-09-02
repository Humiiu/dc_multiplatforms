import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';

/// Admin: daftar siswa terdaftar + total utang aktif.
class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Siswa', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 4),
              Text(
                'Daftar siswa yang terdaftar',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: usersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => AppErrorWidget(
                    message: 'Gagal memuat siswa: $e',
                    onRetry: () {
                      ref.invalidate(adminUsersProvider);
                      ref.invalidate(adminOrdersProvider);
                    },
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada siswa terdaftar.',
                          style: AppTextStyles.bodySmall,
                        ),
                      );
                    }

                    // Map order -> userId -> total unpaid
                    final orders = ordersAsync.valueOrNull ?? [];
                    final debtByUser = <String, int>{};
                    for (final o in orders) {
                      if (o.isPaid) continue;
                      debtByUser[o.userId] =
                          (debtByUser[o.userId] ?? 0) + o.totalPrice;
                    }

                    // Non-admin users only
                    final students =
                        users.where((u) => u.role != UserRole.admin).toList()
                          ..sort((a, b) => a.name.compareTo(b.name));

                    final isWide = MediaQuery.of(context).size.width >= 700;
                    if (isWide) {
                      return _UsersTable(
                        users: students,
                        debtByUser: debtByUser,
                      );
                    }
                    return ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _UserCard(
                        user: students[i],
                        debt: debtByUser[students[i].uid] ?? 0,
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

class _UserCard extends StatelessWidget {
  final AppUser user;
  final int debt;

  const _UserCard({required this.user, required this.debt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyMediumBold,
                )
              : null,
        ),
        title: Text(user.name, style: AppTextStyles.bodyMediumBold),
        subtitle: Text(
          '${user.username} · ${user.kelas.label} ${user.jurusan.label}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Utang',
              style: AppTextStyles.caption,
            ),
            Text(
              AppFormatters.rupiah(debt),
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: debt > 0 ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<AppUser> users;
  final Map<String, int> debtByUser;

  const _UsersTable({required this.users, required this.debtByUser});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Kelas')),
            DataColumn(label: Text('Jurusan')),
            DataColumn(label: Text('No. HP')),
            DataColumn(label: Text('Utang Aktif')),
          ],
          rows: [
            for (final u in users)
              DataRow(
                cells: [
                  DataCell(Text(u.name)),
                  DataCell(Text(u.username)),
                  DataCell(Text(u.kelas.label)),
                  DataCell(Text(u.jurusan.label)),
                  DataCell(Text(u.phone)),
                  DataCell(
                    Text(
                      AppFormatters.rupiah(debtByUser[u.uid] ?? 0),
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: (debtByUser[u.uid] ?? 0) > 0
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
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
