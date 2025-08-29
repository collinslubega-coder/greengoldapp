// lib/screens/admin/views/admin_order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailsScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.order.isCompleted;
  }

  Future<void> _toggleOrderStatus(bool value) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final orderService = Provider.of<OrderService>(context, listen: false);

    try {
      await orderService.updateOrderStatus(widget.order.id, value);
      
      if (!mounted) return;

      setState(() {
        _isCompleted = value;
      });
      // Pass back 'true' to signal that the list should be refreshed
      Navigator.pop(context, true);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Order marked as ${value ? "Completed" : "Pending"}'),
          backgroundColor: successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to update order status.'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    final dateFormatter = DateFormat('d MMMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(title: Text("Order #${widget.order.id}")),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          // --- NEW BUTTON ADDED HERE ---
          ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: const Text("Prepare Confirmation Message"),
            onPressed: () {
              Navigator.pushNamed(
                context, 
                adminConfirmOrderScreenRoute, 
                arguments: widget.order
              );
            },
          ),
          const SizedBox(height: defaultPadding),
          // --- END OF NEW BUTTON ---

          Card(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer: ${widget.order.customerName ?? 'N/A'}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("Contact: ${widget.order.customerContact ?? 'N/A'}"),
                  const SizedBox(height: 8),
                  Text("Address: ${widget.order.deliveryAddress ?? 'N/A'}"),
                  const Divider(height: 24),
                  Text("Date: ${dateFormatter.format(widget.order.createdAt)}"),
                  Text("Subtotal: ${currencyFormatter.format(widget.order.total ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          Card(
            margin: const EdgeInsets.only(top: defaultPadding),
            child: SwitchListTile(
              title: const Text(
                "Mark as Completed",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _isCompleted,
              onChanged: _toggleOrderStatus,
              secondary: Icon(
                _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _isCompleted ? successColor : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),
          Text("Items", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          if (widget.order.items.isEmpty)
            const Card(child: ListTile(title: Text("No items found for this order.")))
          else
            ...widget.order.items.map((item) {
              final product = item.product;
              if (product == null) return const ListTile(title: Text("Product details not found."));

              final isFlower = product.category == 'Flowers';
              String title = isFlower ? product.strainName ?? 'Flower' : product.strainName ?? 'Product';
              String subtitle = "Qty: ${item.quantity}";
              if (item.selectedForm != null) {
                subtitle += " - Form: ${item.selectedForm}";
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: Text(currencyFormatter.format(product.price ?? 0)),
                ),
              );
            }),
        ],
      ),
    );
  }
}