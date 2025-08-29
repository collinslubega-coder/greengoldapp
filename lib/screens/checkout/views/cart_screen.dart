// lib/screens/checkout/views/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/cart_service.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'components/cart_item_card.dart';
import 'components/order_summery.dart';
import 'components/user_info_popup.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _handleCheckout(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    final List<OrderItem> orderItems = cartService.items.map((cartItem) {
      return OrderItem(
        id: 0,
        orderId: 0,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        selectedForm: cartItem.selectedForm,
      );
    }).toList();

    final total = cartService.subtotal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => UserInfoPopup(
        onSave: (name, phone, address) {
          final userDataService =
              Provider.of<UserDataService>(context, listen: false);
          try {
            userDataService.addOrder(
              items: orderItems,
              total: total,
              customerName: name,
              customerContact: phone,
              deliveryAddress: address,
            );

            cartService.clearCart();
            Navigator.pop(context);
            Navigator.pushNamed(context, thanksForOrderScreenRoute,
                arguments: total);
          } catch (e) {
            showErrorSnackBar(
                context, "Failed to place order: ${e.toString()}");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double floatingBarHeight = 64.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          return cartService.items.isEmpty
              ? const Center(
                  child: Text("Your Cart is empty.",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(defaultPadding),
                        itemCount: cartService.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: defaultPadding),
                        itemBuilder: (context, index) {
                          final item = cartService.items[index];
                          return CartItemCard(item: item);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: defaultPadding,
                        top: defaultPadding,
                        bottom: defaultPadding +
                            bottomPadding +
                            floatingBarHeight,
                      ),
                      child: Column(
                        children: [
                          OrderSummaryCard(subTotal: cartService.subtotal),
                          const SizedBox(height: defaultPadding),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _handleCheckout(context),
                              // --- FIX IS HERE ---
                              // The button text is updated.
                              child: const Text("Place Order"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}