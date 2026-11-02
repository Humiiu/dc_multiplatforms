import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu.dart';
import '../services/database_service.dart';
import '../ui/demo_state.dart';
import '../ui/home_page.dart';

/// Provider data menu mingguan dari Firebase Realtime Database
/// Menggunakan fallback ke menu default jika database belum terisi atau offline.
final weeklyMenuProvider = FutureProvider<List<CateringDayMenu>>((ref) async {
  final db = ref.read(databaseServiceProvider);
  try {
    final rawMap = await db.getWeeklyMenu();
    if (rawMap.isEmpty) {
      return CateringDayMenu.defaultWeeklyMenu;
    }

    final dayOrder = ['senin', 'selasa', 'rabu', 'kamis', 'jumat'];
    final List<CateringDayMenu> menus = [];

    for (final day in dayOrder) {
      if (rawMap.containsKey(day)) {
        final val = rawMap[day];
        if (val is Map) {
          // Bila node berstruktur menus/{day}/{item_id}
          if (val.containsKey('title') || val.containsKey('name')) {
            menus.add(CateringDayMenu.fromMap(day, val));
          } else if (val.values.isNotEmpty && val.values.first is Map) {
            menus.add(CateringDayMenu.fromMap(day, val.values.first as Map));
          } else {
            menus.add(_findDefaultMenu(day));
          }
        } else {
          menus.add(_findDefaultMenu(day));
        }
      } else {
        menus.add(_findDefaultMenu(day));
      }
    }

    return menus;
  } catch (_) {
    return CateringDayMenu.defaultWeeklyMenu;
  }
});

CateringDayMenu _findDefaultMenu(String dayKey) {
  return CateringDayMenu.defaultWeeklyMenu.firstWhere(
    (m) => m.key == dayKey.toLowerCase(),
    orElse: () => CateringDayMenu(
      key: dayKey,
      name: dayKey,
      dayLabel: dayKey,
      title: 'Menu $dayKey',
      description: 'Paket Katering Lengkap',
    ),
  );
}

/// Provider HomeMenuItem untuk carousel di HomePage
final homeMenuItemsProvider = Provider<List<HomeMenuItem>>((ref) {
  final asyncMenus = ref.watch(weeklyMenuProvider);
  final menus = asyncMenus.value ?? CateringDayMenu.defaultWeeklyMenu;

  return menus.map((m) {
    return HomeMenuItem(
      dayLabel: m.dayLabel,
      title: m.title,
      subtitle: m.description,
      image: m.imageUrl,
    );
  }).toList();
});

/// Provider daftar hari untuk OrderPage
final orderDaysProvider = Provider<List<DemoDay>>((ref) {
  final asyncMenus = ref.watch(weeklyMenuProvider);
  final menus = asyncMenus.value ?? CateringDayMenu.defaultWeeklyMenu;

  return menus.map((m) {
    return DemoDay(
      key: m.key,
      name: m.name,
      menu: m.description.isNotEmpty ? m.description : m.title,
    );
  }).toList();
});
