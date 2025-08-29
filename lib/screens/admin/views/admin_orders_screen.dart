// lib/screens/admin/views/admin_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // This service will now be fetched from the UserDataService
  // late final OrderService _orderService;

  // @override
  // void initState() {
  //   super.initState();
  //   // Access the OrderService via UserDataService
  //   _orderService = Provider.of<UserDataService>(context, listen: false).orderService;
  // }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');

    return Scaffold(
      // --- FIX IS HERE ---
      // This screen now has its own AppBar for better navigation and context.
      appBar: AppBar(
        title: const Text("Manage Orders"),
      ),
      body: Consumer<UserDataService>(
        builder: (context, userDataService, child) {
          final List<Order> orders = userDataService.orders;

          return RefreshIndicator(
            onRefresh: () => userDataService.refreshOrders(),
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      "No orders found.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                        ),
                        child: ListTile(
                          onTap: () async {
                            // Navigate and wait for a potential update
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminOrderDetailsScreen(order: order),
                              ),
                            );
                            // Refresh the list if the details screen signaled an update
                            if (result == true) {
                               userDataService.refreshOrders();
                            }
                          },
                          title: Text(order.customerName ?? 'N/A'),
                          subtitle: Text("Status: ${order.isCompleted ? 'Completed' : 'Pending'}"),
                          trailing: Text(currencyFormatter.format(order.total ?? 0)),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}