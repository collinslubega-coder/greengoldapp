// lib/models/cart_item_model.dart

import 'package:green_gold/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? selectedForm; // e.g., "Bud" or "Pre-roll"

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedForm,
  });
}