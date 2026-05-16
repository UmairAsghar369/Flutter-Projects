import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

/// Global cart state managed via ChangeNotifier (Provider pattern).
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Unmodifiable view of cart items.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Total number of individual items in the cart.
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Dynamically calculated total price.
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Add a product to the cart. If it already exists, increment quantity.
  void addItem(Product product, int quantity) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Remove a product entirely from the cart.
  void removeItem(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  /// Change quantity by [delta]. Enforces min = 1; removes if below 1.
  void updateQuantity(String productId, int delta) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity < 1) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Clear the entire cart (used after checkout).
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
