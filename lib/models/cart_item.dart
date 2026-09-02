class CartItem {
  final String day;
  final String menuId;
  final String menuName;
  final int price;
  int quantity;

  CartItem({
    required this.day,
    required this.menuId,
    required this.menuName,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
        'day': day,
        'menuId': menuId,
        'menuName': menuName,
        'price': price,
        'quantity': quantity,
      };
}
