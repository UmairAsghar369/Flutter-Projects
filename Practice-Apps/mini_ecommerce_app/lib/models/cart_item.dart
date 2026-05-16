import 'product.dart';

/// CartItem wraps a Product with a mutable quantity for the shopping cart.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Total price for this line item.
  double get lineTotal => product.price * quantity;
}
