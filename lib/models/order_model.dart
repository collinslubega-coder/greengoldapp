// lib/models/order_model.dart

import 'package:green_gold/models/product_model.dart';

class Order {
  final int id;
  final String userId;
  final String? customerName;
  final String? customerContact;
  final String? deliveryAddress;
  final double? total;
  final bool isCompleted; // REPLACED status with isCompleted
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    this.customerName,
    this.customerContact,
    this.deliveryAddress,
    this.total,
    required this.isCompleted, // CHANGED
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json, List<OrderItem> items) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      customerName: json['customer_name'] as String?,
      customerContact: json['customer_contact'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false, // CHANGED
      createdAt: DateTime.parse(json['created_at'] as String),
      items: items,
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final String? selectedForm;
  final Product? product; 

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.selectedForm,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json, {Product? product}) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      selectedForm: json['selected_form'] as String?,
      product: product,
    );
  }
}