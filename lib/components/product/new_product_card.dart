// lib/components/product/new_product_card.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';

class NewProductCard extends StatelessWidget {
  final String productName;
  final String? imageUrl;
  final VoidCallback press;

  const NewProductCard({
    super.key,
    required this.productName,
    required this.imageUrl,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Card(
        elevation: 0.5,
        shadowColor: Colors.black12,
        color: Theme.of(context).colorScheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              // Use the consistent image loader
              child: NetworkImageWithLoader(
                imageUrl,
                radius: 0, // No radius for the top part of the card
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding / 2),
                child: Center(
                  child: Text(
                    productName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}