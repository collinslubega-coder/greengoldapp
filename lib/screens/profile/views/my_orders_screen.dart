// lib/screens/profile/views/my_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'components/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: Consumer<UserDataService>(
        builder: (context, userDataService, child) {
          return RefreshIndicator(
            onRefresh: () => userDataService.refreshOrders(),
            child: userDataService.orders.isEmpty
                ? const Center(
                    child: Text(
                      "You have no orders yet.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: userDataService.orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      return OrderCard(order: userDataService.orders[index]);
                    },
                  ),
          );
        },
      ),
    );
  }
}