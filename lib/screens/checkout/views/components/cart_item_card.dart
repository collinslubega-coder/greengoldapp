// lib/screens/checkout/views/components/cart_item_card.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/cart_item_model.dart';
import 'package:green_gold/services/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    final price = item.product.price ?? 0.0;
    final product = item.product;

    String title = product.strainName ?? 'Product';
    if (product.category == 'Flowers') {
      title = "${product.type} - ${product.generation}";
    }
    
    String subtitle = product.strainName ?? '';
    if (item.selectedForm != null) {
      subtitle += " - ${item.selectedForm}";
    }

    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: NetworkImageWithLoader(product.imageUrl, radius: 16),
          ),
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge, maxLines: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: defaultPadding / 2),
              Text(
                currencyFormatter.format(price),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        // NEW: Quantity adjustment and remove buttons
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => cartService.increaseQuantity(item),
            ),
            Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(
                item.quantity > 1 ? Icons.remove_circle_outline : Icons.delete_outline,
                size: 20,
                color: item.quantity > 1 ? null : errorColor,
              ),
              onPressed: () {
                if (item.quantity > 1) {
                  cartService.decreaseQuantity(item);
                } else {
                  cartService.removeItem(item);
                }
              },
            ),
          ],
        )
      ],
    );
  }
}