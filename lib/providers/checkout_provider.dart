import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CheckoutState {
  final List<CartItem> items;
  final int total;
  final List<String>? existingOrderIds;

  CheckoutState({
    required this.items,
    required this.total,
    this.existingOrderIds,
  });

  bool get isPayingExistingDebt => existingOrderIds != null && existingOrderIds!.isNotEmpty;
}

final checkoutProvider = StateProvider<CheckoutState?>((ref) => null);
