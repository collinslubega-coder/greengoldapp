// lib/admin_entry_point.dart

import 'package:flutter/material.dart';
import 'package:green_gold/entry_point.dart';
import 'package:green_gold/screens/admin/views/admin_dashboard_screen.dart';
import 'package:green_gold/screens/admin/views/admin_lobby_screen.dart';
import 'package:green_gold/screens/settings/views/settings_screen.dart';

class AdminEntryPoint extends StatefulWidget {
  const AdminEntryPoint({super.key});

  @override
  State<AdminEntryPoint> createState() => _AdminEntryPointState();
}

class _AdminEntryPointState extends State<AdminEntryPoint> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminLobbyScreen(),
    const SettingsScreen(),
  ];

  final List<String> _pageTitles = [
    "Sales Dashboard",
    "Admin Lobby",
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: "View Customer Shop",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EntryPoint(showReturnBanner: true)),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            label: 'Lobby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}