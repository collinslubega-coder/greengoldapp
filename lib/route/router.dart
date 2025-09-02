// lib/route/router.dart

import 'package:flutter/material.dart';
import 'package:green_gold/entry_point.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/route/screen_export.dart';
import 'package:green_gold/screens/admin/views/admin_confirm_order_screen.dart';
import 'package:green_gold/screens/admin/views/admin_hubs_screen.dart';
import 'package:green_gold/screens/admin/views/admin_lobby_screen.dart';
import 'package:green_gold/screens/admin/views/admin_music_screen.dart';
import 'package:green_gold/screens/admin/views/admin_products_screen.dart';
import 'package:green_gold/screens/checkout/views/cart_screen.dart';
// --- FIX IS HERE: Added the missing import for the new screen ---
import 'package:green_gold/screens/hubs/entertainment_hub/views/cast_detail_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Core App Routes
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (_) => const OnBordingScreen());
    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const EntryPoint());
    case passwordScreenRoute:
      return MaterialPageRoute(builder: (_) => const PasswordScreen());
    case userLoginScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserLoginScreen());

    // Product & Checkout Routes
    case groupedProductDetailsScreenRoute:
      if (settings.arguments is List<Product>) {
        final products = settings.arguments as List<Product>;
        return MaterialPageRoute(
            builder: (_) => GroupedProductDetailScreen(products: products));
      }
      return _errorRoute();
    case cartScreenRoute:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case thanksForOrderScreenRoute:
      if (settings.arguments is double) {
        final amount = settings.arguments as double;
        return MaterialPageRoute(
            builder: (_) => ThanksForOrderScreen(amount: amount));
      }
      return _errorRoute();

    // Profile & Settings Routes
    case myOrdersScreenRoute:
      return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
    case faqScreenRoute:
      return MaterialPageRoute(builder: (_) => const FaqScreen());
    case safetyTipsAndGuidesScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const SafetyTipsAndGuidesScreen());
    case supportCenterRoute:
      return MaterialPageRoute(builder: (_) => const SupportCenterScreen());
    case settingsScreenRoute:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());

    // Hubs Routes
    case castDetailScreenRoute:
      if (settings.arguments is int) {
        final personId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => CastDetailScreen(personId: personId));
      }
      return _errorRoute();
    
    // Admin Routes
    case adminAuthScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminAuthScreen());
    case adminOrderDetailsScreenRoute:
      if (settings.arguments is Order) {
        final order = settings.arguments as Order;
        return MaterialPageRoute(
            builder: (_) => AdminOrderDetailsScreen(order: order));
      }
      return _errorRoute();
    case adminConfirmOrderScreenRoute:
      if (settings.arguments is Order) {
        final order = settings.arguments as Order;
        return MaterialPageRoute(
            builder: (_) => AdminConfirmOrderScreen(order: order));
      }
      return _errorRoute();
    case contactSettingsScreenRoute:
      return MaterialPageRoute(builder: (_) => const ContactSettingsScreen());
    case addEditSettingScreenRoute:
       final setting = settings.arguments as MapEntry<String, String>?;
       return MaterialPageRoute(builder: (_) => AddEditSettingScreen(setting: setting));
    case adminProductsScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
    case adminLobbyScreenRoute:
       return MaterialPageRoute(builder: (_) => const AdminLobbyScreen());
    case adminHubsScreenRoute:
       return MaterialPageRoute(builder: (_) => const AdminHubsScreen());
    case adminMusicScreenRoute:
       return MaterialPageRoute(builder: (_) => const AdminMusicScreen());

    default:
      // Default to the main entry point if a route is not found
      return MaterialPageRoute(builder: (_) => const EntryPoint());
  }
}

// A helper function to return a generic error screen or redirect
Route<dynamic> _errorRoute() {
  return MaterialPageRoute(builder: (_) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text('Something went wrong. Please try again.'),
      ),
    );
  });
}