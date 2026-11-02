import 'package:flutter_test/flutter_test.dart';
import 'package:dc_multiplatforms/models/menu.dart';

void main() {
  group('CateringDayMenu model', () {
    test('defaultWeeklyMenu returns 5 days with correct flat price', () {
      final menus = CateringDayMenu.defaultWeeklyMenu;
      expect(menus.length, 5);
      expect(menus.map((m) => m.key).toList(), ['senin', 'selasa', 'rabu', 'kamis', 'jumat']);
      for (final menu in menus) {
        expect(menu.price, 20000);
        expect(menu.title, isNotEmpty);
        expect(menu.description, isNotEmpty);
      }
    });

    test('fromMap parses custom values properly', () {
      final map = {
        'name': 'Senin',
        'dayLabel': 'Senin, 10 Nov',
        'title': 'Ayam Geprek Sambal Matah',
        'description': 'Nasi, lalapan, tahu tempe',
        'price': 20000,
        'imageUrl': 'https://example.com/food.jpg',
        'isAvailable': true,
      };

      final menu = CateringDayMenu.fromMap('senin', map);
      expect(menu.key, 'senin');
      expect(menu.name, 'Senin');
      expect(menu.dayLabel, 'Senin, 10 Nov');
      expect(menu.title, 'Ayam Geprek Sambal Matah');
      expect(menu.description, 'Nasi, lalapan, tahu tempe');
      expect(menu.price, 20000);
      expect(menu.imageUrl, 'https://example.com/food.jpg');
      expect(menu.isAvailable, isTrue);
    });

    test('fromMap provides safe fallbacks for missing fields', () {
      final map = <String, dynamic>{};
      final menu = CateringDayMenu.fromMap('selasa', map);

      expect(menu.key, 'selasa');
      expect(menu.name, 'Selasa');
      expect(menu.price, 20000);
      expect(menu.isAvailable, isTrue);
    });

    test('toMap serializes properly', () {
      const menu = CateringDayMenu(
        key: 'rabu',
        name: 'Rabu',
        dayLabel: 'Rabu, 12 Nov',
        title: 'Bebek Goreng',
        description: 'Sambal korek',
        price: 20000,
      );

      final map = menu.toMap();
      expect(map['key'], 'rabu');
      expect(map['name'], 'Rabu');
      expect(map['title'], 'Bebek Goreng');
      expect(map['price'], 20000);
    });
  });
}
