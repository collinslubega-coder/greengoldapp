// lib/screens/checkout/views/components/order_summery.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:intl/intl.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.subTotal,
  });

  final double subTotal;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');

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
              Text("Subtotal (Items)", style: Theme.of(context).textTheme.bodyMedium),
              Text(currencyFormatter.format(subTotal),
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: defaultPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery fee",
                  style: Theme.of(context).textTheme.bodyMedium),
              // --- FIX IS HERE ---
              // The delivery fee is now shown as "To Be Confirmed".
              Text("To Be Confirmed",
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
              Text("${currencyFormatter.format(subTotal)} + Delivery",
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}