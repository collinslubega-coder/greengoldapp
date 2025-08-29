// lib/screens/home/views/components/grouped_product_card.dart

import 'package:flutter/material.dart';
import 'package:green_gold/models/product_model.dart';

class GroupedProductCard extends StatelessWidget {
  const GroupedProductCard({
    super.key,
    required this.product,
    required this.press,
  });

  final Product product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Card(
        child: Column(
          children: [
            // FIX: Use the 'imageUrl' property from the new Product model
            Image.network(product.imageUrl ?? '', height: 100),
            // FIX: Use the 'strainName' property for the name
            Text(product.strainName ?? 'Unnamed Product'),
          ],
        ),
      ),
    );
  }
}