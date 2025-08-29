// lib/screens/profile/views/components/order_card.dart

import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../models/order_model.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;
  static const String _placeholderImagePath = 'assets/images/no_image_available.png';

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    final dateFormatter = DateFormat('d MMMM yyyy, hh:mm a');

    // Create a descriptive title from the order items
    final String productInfoTitle = order.items.map((item) {
      final productName = item.product?.strainName ?? 'Item';
      return "$productName (x${item.quantity})";
    }).join(', ');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultBorderRadious)),
      color: Theme.of(context).colorScheme.surface,
      child: ExpansionTile(
        title: Text(productInfoTitle, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
        subtitle: Text(dateFormatter.format(order.createdAt)),
        trailing: Text(currencyFormatter.format(order.total ?? 0), style: TextStyle(color: Theme.of(context).primaryColor)),
        children: [
          ...order.items.map(
            (item) {
              final product = item.product;
              if (product == null) return const SizedBox.shrink();

              String title = product.strainName ?? 'Product';
              if (product.category == 'Flowers') {
                title = "${product.type} ${product.generation}";
              }
              String subtitle = item.selectedForm != null ? "Form: ${item.selectedForm}" : "Category: ${product.category}";

              return ListTile(
                leading: Image.network(
                  product.imageUrl ?? _placeholderImagePath,
                  width: 40,
                  errorBuilder: (c, e, s) => Image.asset(_placeholderImagePath, width: 40),
                ),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: Text(currencyFormatter.format(product.price ?? 0.0)),
              );
            }
          ),
        ],
      ),
    );
  }
}