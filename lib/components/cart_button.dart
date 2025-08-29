// lib/components/cart_button.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.price,
    this.title = "Add To Cart",
    required this.press,
  });

  // REMOVED: The 'subTitle' parameter which was part of the problem.
  final double price;
  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: press,
            // FIX: The child is now a simple Row with two Text widgets,
            // which guarantees it will fit and be responsive.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormatter.format(price),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}