// lib/screens/checkout/views/thanks_for_order_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:intl/intl.dart';

class ThanksForOrderScreen extends StatelessWidget {
  const ThanksForOrderScreen({super.key, required this.amount, this.arguments});

  final double amount;
  final Object? arguments;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final String imagePath = isDarkMode
        ? "assets/Illustration/success_dark.png"
        : "assets/Illustration/success_light.png";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          )
        ],
      ),
      // --- FIX IS HERE ---
      // Wrap the body in a SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: defaultPadding * 2),
              Image.asset(
                imagePath,
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              const SizedBox(height: defaultPadding * 2),
              Text(
                "Thanks for your order",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                "Your order is now being processed. We will contact you shortly to confirm the details.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding * 2),
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order number"),
                        Text(
                          "#FDS639820",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Amount paid"),
                        Text(
                          currencyFormatter.format(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding * 3), // Added more spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    entryPointScreenRoute,
                    (route) => false,
                  );
                },
                child: const Text("Continue Shopping"),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}