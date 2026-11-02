/// Model menu catering harian Dian Catering.
class MenuItem {
  final String id;
  final String name;
  final int price; // dalam Rupiah (flat Rp 20.000)
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory MenuItem.fromMap(String id, Map<dynamic, dynamic> map) => MenuItem(
        id: id,
        name: (map['name'] ?? map['title'] ?? '') as String,
        price: ((map['price'] ?? 20000) as num).toInt(),
        imageUrl: map['imageUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

/// Model menu per hari untuk carousel Home dan pilihan Order
class CateringDayMenu {
  final String key; // 'senin', 'selasa', 'rabu', 'kamis', 'jumat'
  final String name; // 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
  final String dayLabel; // 'Senin, 27 Okt'
  final String title; // 'Ayam Telor Asin'
  final String description; // 'Nasi Liwet, Ayam Goreng, Tempe-Goreng, Sambal'
  final int price; // default Rp 20.000
  final String? imageUrl;
  final bool isAvailable;

  const CateringDayMenu({
    required this.key,
    required this.name,
    required this.dayLabel,
    required this.title,
    required this.description,
    this.price = 20000,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory CateringDayMenu.fromMap(String key, Map<dynamic, dynamic> map) {
    final dayNames = {
      'senin': 'Senin',
      'selasa': 'Selasa',
      'rabu': 'Rabu',
      'kamis': 'Kamis',
      'jumat': 'Jumat',
    };
    final normalizedKey = key.toLowerCase();
    final name = (map['name'] as String?) ?? dayNames[normalizedKey] ?? key;
    final dayLabel = (map['dayLabel'] as String?) ?? name;
    final title = (map['title'] ?? map['name'] ?? 'Menu $name') as String;
    final description = (map['description'] ?? map['menu'] ?? map['subtitle'] ?? '') as String;
    final price = ((map['price'] ?? 20000) as num).toInt();
    final imageUrl = map['imageUrl'] as String?;
    final isAvailable = (map['isAvailable'] as bool?) ?? true;

    return CateringDayMenu(
      key: normalizedKey,
      name: name,
      dayLabel: dayLabel,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'name': name,
        'dayLabel': dayLabel,
        'title': title,
        'description': description,
        'price': price,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isAvailable': isAvailable,
      };

  static List<CateringDayMenu> get defaultWeeklyMenu => const [
        CateringDayMenu(
          key: 'senin',
          name: 'Senin',
          dayLabel: 'Senin, 27 Okt',
          title: 'Ayam Telor Asin',
          description: 'Nasi Liwet, Ayam Goreng, Tempe-Goreng, Sambal',
          price: 20000,
        ),
        CateringDayMenu(
          key: 'selasa',
          name: 'Selasa',
          dayLabel: 'Selasa, 28 Okt',
          title: 'Mie Chili Oil',
          description: 'Ayam Telur Asin, Martabak tahu, Kacang panjang',
          price: 20000,
        ),
        CateringDayMenu(
          key: 'rabu',
          name: 'Rabu',
          dayLabel: 'Rabu, 29 Okt',
          title: 'Ayam Hot Lava',
          description: 'Ayam HotLava, Tahu Krispi, Timun',
          price: 20000,
        ),
        CateringDayMenu(
          key: 'kamis',
          name: 'Kamis',
          dayLabel: 'Kamis, 30 Okt',
          title: 'Ayam Teriyaki',
          description: 'Ayam Teriyaki, Nasi, Sayuran, Wijen',
          price: 20000,
        ),
        CateringDayMenu(
          key: 'jumat',
          name: 'Jumat',
          dayLabel: 'Jumat, 31 Okt',
          title: 'Nasi Goreng Spesial',
          description: 'Nasi Goreng Spesial, Telur, Ayam Suwir, Kerupuk',
          price: 20000,
        ),
      ];
}
