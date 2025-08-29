// lib/screens/settings/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/screens/login/views/splash_screen.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:green_gold/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (mounted) {
      setState(() {
        _notificationsEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications ${value ? "enabled" : "disabled"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ** THE FIX IS HERE: The screen now has its own Scaffold and a permanent AppBar **
    return Scaffold(
      appBar: AppBar(
        // This ensures a back button won't show when it's a main tab.
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserDataService>(
        builder: (context, userDataService, child) {
          return ListView(
            padding: const EdgeInsets.all(defaultPadding),
            children: [
              SwitchListTile(
                title: const Text("Enable Notifications"),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                secondary: const Icon(Icons.notifications_active_outlined),
              ),
              SwitchListTile(
                title: const Text("Theme"),
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
                secondary: const Icon(Icons.contrast),
              ),
              const Divider(height: defaultPadding * 2),
              ListTile(
                leading: const Icon(Icons.logout, color: errorColor),
                title: const Text("Logout", style: TextStyle(color: errorColor)),
                onTap: () async {
                  await userDataService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}