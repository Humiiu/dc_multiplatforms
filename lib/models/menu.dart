/// Model menu catering harian.
class MenuItem {
  final String id;
  final String name;
  final int price; // dalam Rupiah
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory MenuItem.fromMap(String id, Map<dynamic, dynamic> map) => MenuItem(
        id: id,
        name: (map['name'] ?? '') as String,
        price: ((map['price'] ?? 0) as num).toInt(),
        imageUrl: map['imageUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
