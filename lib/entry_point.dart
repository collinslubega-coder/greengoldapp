// lib/entry_point.dart

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/screens/checkout/views/cart_screen.dart';
import 'package:green_gold/screens/home/views/home_screen.dart';
import 'package:green_gold/screens/profile/views/profile_screen.dart';
import 'package:green_gold/screens/settings/views/settings_screen.dart';

class EntryPoint extends StatefulWidget {
  final bool showReturnBanner;
  final int initialIndex; // ** NEW: To handle navigation from widget **
  const EntryPoint({
    super.key, 
    this.showReturnBanner = false,
    this.initialIndex = 0, // ** NEW: Default to 0 **
  });

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late int _pageIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex; // ** NEW: Set initial index from widget property **
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: widget.showReturnBanner
          ? AppBar(
              leading: const BackButton(),
              title: const Text("Customer Shop View"),
              elevation: 0,
            )
          : null,
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex, // ** Ensure this uses the state variable **
        items: const <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.white),
          Icon(Icons.apps_outlined, size: 30, color: Colors.white),
          Icon(Icons.settings_outlined, size: 30, color: Colors.white),
        ],
        color: primaryColor,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: primaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}