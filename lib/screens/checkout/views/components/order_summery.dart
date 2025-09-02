// lib/screens/checkout/components/order_summery.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:intl/intl.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.subTotal,
    required this.totalQuantity,
    this.unitOfSale,
  });

  final double subTotal;
  final int totalQuantity;
  final String? unitOfSale;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    const double deliveryFee = 0.0;
    final double total = subTotal + deliveryFee;

    // This logic correctly handles singular vs. plural units.
    String getQuantityDisplay() {
      if (unitOfSale == null) {
        // If units are mixed, just show the number
        return totalQuantity.toString();
      }
      if (totalQuantity == 1) {
        // If quantity is 1, show the singular unit (e.g., "1 gram")
        return '1 $unitOfSale';
      }
      // Otherwise, show the plural unit (e.g., "5 grams")
      return '$totalQuantity ${unitOfSale}s';
    }

    final String quantityDisplay = getQuantityDisplay();

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: Theme.of(context).textTheme.bodyMedium),
              Text(currencyFormatter.format(subTotal),
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: defaultPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Items", style: Theme.of(context).textTheme.bodyMedium),
              Text(quantityDisplay,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: defaultPadding),
          const Divider(),
          const SizedBox(height: defaultPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: Theme.of(context).textTheme.titleSmall),
              Text(currencyFormatter.format(total),
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
