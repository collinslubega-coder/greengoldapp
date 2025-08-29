// lib/services/user_data_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'order_service.dart';
import 'package:green_gold/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class UserDataService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final OrderService orderService;

  String? _userName;
  List<String> _addresses = [];
  List<Order> _orders = [];
  List<String>? _userContacts;
  String? _userRole;
  String? _trueUserRole;

  final Completer<void> _initializedCompleter = Completer<void>();
  Future<void> get initialized => _initializedCompleter.future;

  String? get userName => _userName;
  List<String> get addresses => _addresses;
  List<Order> get orders => _orders;
  List<String>? get userContacts => _userContacts;
  String? get userRole => _userRole;
  String? get trueUserRole => _trueUserRole;

  UserDataService({required NotificationService notificationService})
      : orderService = OrderService(notificationService: notificationService) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;
      if (session != null) {
        await _loadUserProfile(session.user.id);
        await refreshOrders();
      } else {
        _userName = null;
        _userRole = null;
        _trueUserRole = null;
        _orders = [];
        _addresses = [];
        _userContacts = [];
      }
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase.from('profiles').select('name, role, delivery_address, contact').eq('id', userId).single();
      _userName = response['name'];
      _userRole = response['role'];
      _trueUserRole = response['role'];
      _addresses = (response['delivery_address'] as String? ?? '').split(',').where((a) => a.isNotEmpty).toList();
      _userContacts = (response['contact'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> refreshOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    // --- FIX IS HERE ---
    // The logic is now correct. If the user is an admin, fetch all orders. Otherwise, pass the customer's userId.
    if (_userRole == 'admin') {
      _orders = await orderService.fetchOrders();
    } else if (userId != null) {
      _orders = await orderService.fetchOrders(userId: userId);
    }
    notifyListeners();
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  Future<void> login({required String role, String? pin}) async {
    if (role == 'customer') {
      await _supabase.auth.signInAnonymously();
    } else {
      if (pin == null || pin.isEmpty) throw Exception("PIN is required for staff login.");
      final response = await _supabase
          .from('profiles')
          .select('email')
          .eq('pin_hash', _hashPin(pin))
          .single();
      await _supabase.auth.signInWithPassword(email: response['email'], password: "babyco@1234");
    }
  }

  Future<void> addOrder({
    required List<OrderItem> items,
    required double total,
    required String customerName,
    required String customerContact,
    required String deliveryAddress,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    final order = Order(
      id: 0,
      userId: userId,
      customerName: customerName,
      customerContact: customerContact,
      deliveryAddress: deliveryAddress,
      total: total,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await orderService.createOrder(order, items);
    await refreshOrders();
  }

  Future<void> updateUserInfoAndAddress({required String name, required String contact, required String address}) async {
      final userId = _supabase.auth.currentUser?.id;
      if(userId == null) return;
      await _supabase.from('profiles').upsert({'id': userId, 'name': name, 'contact': [contact], 'delivery_address': address});
      await _loadUserProfile(userId);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}