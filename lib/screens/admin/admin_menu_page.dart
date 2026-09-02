import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/menu.dart';
import '../../providers/admin_provider.dart';
import '../../services/database_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';

/// Admin: kelola menu mingguan (Senin–Jumat).
class AdminMenuPage extends ConsumerStatefulWidget {
  const AdminMenuPage({super.key});

  @override
  ConsumerState<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends ConsumerState<AdminMenuPage> {
  int _selectedDay = 0;

  String get _dayDbKey => hariKerjaDb[_selectedDay];
  String get _dayLabel => hariKerja[_selectedDay];

  Future<void> _openAddDialog(Map<String, dynamic> dayMenus) async {
    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MenuFormDialog(dayKey: _dayDbKey, existing: dayMenus),
    );
    if (updated == null || !mounted) return;
    try {
      await ref.read(databaseServiceProvider).setMenuForDay(
            _dayDbKey,
            updated['id'] as String,
            updated['data'] as Map<String, dynamic>,
          );
      ref.invalidate(adminMenuProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(String menuId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: const Text('Menu ini akan dihapus dari daftar hari ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(databaseServiceProvider)
          .deleteMenuItem(_dayDbKey, menuId);
      ref.invalidate(adminMenuProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(adminMenuProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Atur Menu', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola menu catering minggu ini',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openAddDialog(
                    menuAsync.valueOrNull?[_dayDbKey] is Map
                        ? (menuAsync.valueOrNull![_dayDbKey] as Map)
                            .cast<String, dynamic>()
                        : {},
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Item'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Day selector chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < hariKerja.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(hariKerja[i]),
                        selected: _selectedDay == i,
                        onSelected: (_) => setState(() => _selectedDay = i),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            menuAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: 'Gagal memuat menu: $e',
                onRetry: () => ref.invalidate(adminMenuProvider),
              ),
              data: (weekly) {
                final dayData = weekly[_dayDbKey];
                final dayMenus = dayData is Map
                    ? dayData.cast<String, dynamic>()
                    : <String, dynamic>{};

                if (dayMenus.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: AppColors.borderStrong,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada menu untuk $_dayLabel',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _openAddDialog({}),
                            child: const Text('Tambah menu pertama'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = dayMenus.entries
                    .map((e) => MenuItem.fromMap(e.key, e.value))
                    .toList();

                return LayoutBuilder(
                  builder: (context, c) {
                    final columns = c.maxWidth >= 700 ? 3 : (c.maxWidth >= 480 ? 2 : 1);
                    final spacing = 16.0;
                    final tileWidth =
                        (c.maxWidth - spacing * (columns - 1)) / columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final item in items)
                          SizedBox(
                            width: tileWidth,
                            child: _MenuCard(
                              item: item,
                              dayLabel: _dayLabel,
                              onEdit: () => _openAddDialog(dayMenus),
                              onDelete: () => _deleteItem(item.id),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final String dayLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuCard({
    required this.item,
    required this.dayLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            color: AppColors.secondary,
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.bodyMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppFormatters.rupiah(item.price),
                        style: AppTextStyles.priceMedium.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primary, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuFormDialog extends StatefulWidget {
  final String dayKey;
  final Map<String, dynamic> existing;

  const _MenuFormDialog({required this.dayKey, required this.existing});

  @override
  State<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<_MenuFormDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String? _editingId;

  @override
  void initState() {
    super.initState();
    // Pre-fill with first existing item when editing from a card.
    if (widget.existing.isNotEmpty) {
      final entry = widget.existing.entries.first;
      _editingId = entry.key;
      final item = MenuItem.fromMap(entry.key, entry.value);
      _nameCtrl.text = item.name;
      _priceCtrl.text = item.price.toString();
      _imageCtrl.text = item.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editingId == null ? 'Tambah Menu' : 'Edit Menu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageCtrl,
              decoration: const InputDecoration(
                labelText: 'URL Gambar (opsional)',
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final price = int.tryParse(_priceCtrl.text.trim());
            if (name.isEmpty || price == null || price <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Isi nama menu dan harga yang valid'),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'id': _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
              'data': {
                'name': name,
                'price': price,
                if (_imageCtrl.text.trim().isNotEmpty)
                  'imageUrl': _imageCtrl.text.trim(),
              },
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
