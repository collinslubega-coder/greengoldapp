// lib/services/order_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:green_gold/services/notification_service.dart';

class OrderService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService notificationService;

  OrderService({required this.notificationService});

  Future<void> createOrder(Order order, List<OrderItem> items) async {
    try {
      final orderResponse = await _supabase.from('orders').insert({
        'user_id': order.userId,
        'customer_name': order.customerName,
        'customer_contact': order.customerContact,
        'delivery_address': order.deliveryAddress,
        'total': order.total,
        'is_completed': order.isCompleted,
      }).select().single();

      final newOrderId = orderResponse['id'];

      final itemsToInsert = items
          .map((item) => {
                'order_id': newOrderId,
                'product_id': item.productId,
                'quantity': item.quantity,
                'selected_form': item.selectedForm,
              })
          .toList();

      await _supabase.from('order_items').insert(itemsToInsert);

      await notificationService.showNotification(
        id: newOrderId,
        title: 'New Order Received!',
        body: 'A new order #${newOrderId} has been placed by ${order.customerName}.',
      );

    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<List<Order>> fetchOrders({String? userId}) async {
    try {
      // --- FIX IS HERE ---
      // The query is now structured correctly. The .eq() filter is applied before .order().
      PostgrestFilterBuilder query;
      if (userId != null) {
        query = _supabase.from('orders').select().eq('user_id', userId);
      } else {
        query = _supabase.from('orders').select();
      }
      
      final ordersResponse = await query.order('created_at', ascending: false);
      
      final orderItemsResponse = await _supabase.from('order_items').select();
      final productsResponse = await _supabase.from('products').select();

      final allOrderItems = (orderItemsResponse as List).map((data) => OrderItem.fromJson(data)).toList();
      final allProducts = (productsResponse as List).map((data) => Product.fromJson(data)).toList();

      List<Order> orders = (ordersResponse as List).map((orderData) {
        final orderId = orderData['id'];
        final itemsForThisOrder = allOrderItems.where((item) => item.orderId == orderId).map((item) {
          final productDetails = allProducts.firstWhere((p) => p.id == item.productId, orElse: () => Product(id: 0, category: 'Unknown', isAvailable: false));
          return OrderItem(
            id: item.id,
            orderId: item.orderId,
            productId: item.productId,
            quantity: item.quantity,
            selectedForm: item.selectedForm,
            product: productDetails,
          );
        }).toList();

        return Order.fromJson(orderData, itemsForThisOrder);
      }).toList();

      return orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(int orderId, bool isCompleted) async {
    try {
      await _supabase.from('orders').update({
        'is_completed': isCompleted,
      }).eq('id', orderId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }
}