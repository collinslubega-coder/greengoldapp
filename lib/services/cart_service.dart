// lib/services/cart_service.dart

import 'package:flutter/material.dart';
import 'package:green_gold/models/cart_item_model.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:collection/collection.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Add an item to the cart, now including the selected form
  void addItem(Product product, int quantity, {String? selectedForm}) {
    // A unique identifier for a cart item is now the product ID AND the selected form
    final existingItem = _items.firstWhereOrNull(
      (item) => item.product.id == product.id && item.selectedForm == selectedForm,
    );

    if (existingItem != null) {
      existingItem.quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedForm: selectedForm,
      ));
    }
    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  void increaseQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    }
    notifyListeners();
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) {
      final price = item.product.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}