// lib/screens/admin/views/contact_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:provider/provider.dart';

class ContactSettingsScreen extends StatefulWidget {
  const ContactSettingsScreen({super.key});

  @override
  State<ContactSettingsScreen> createState() => _ContactSettingsScreenState();
}

class _ContactSettingsScreenState extends State<ContactSettingsScreen> {

  final List<String> _managedSettingKeys = [
    'head_office_whatsapp',
    'support_email',
    'company_whatsapp_group_link',
    'tiktok_link',
    'instagram_link',
  ];

  void _deleteSetting(String key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${key.replaceAll('_', ' ').toUpperCase()}"?'),
        content: const Text('Are you sure you want to delete this setting? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        await Provider.of<SettingsService>(context, listen: false).deleteSetting(key);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Setting "$key" has been deleted.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (mounted) {
          showErrorSnackBar(scaffoldMessenger.context, 'Error deleting setting: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact & Link Settings")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, addEditSettingScreenRoute);
        },
        child: const Icon(Icons.add),
        tooltip: "Add New Setting",
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          if (settingsService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settingsList = settingsService.settings.entries
              .where((entry) => _managedSettingKeys.contains(entry.key))
              .toList();

          if (settingsList.isEmpty) {
            return const Center(child: Text("No contact or link settings found. Tap '+' to add one."));
          }

          return RefreshIndicator(
            onRefresh: () => settingsService.initializeSettings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: settingsList.length,
              itemBuilder: (context, index) {
                final setting = settingsList[index];
                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                  child: ListTile(
                    title: Text(setting.key.replaceAll('_', ' ').toUpperCase()),
                    subtitle: Text(setting.value.isEmpty ? "Not set" : setting.value),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              addEditSettingScreenRoute,
                              arguments: setting,
                            );
                          },
                        ),
                        if (setting.value.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: errorColor),
                            onPressed: () => _deleteSetting(setting.key),
                          ),
                      ],
                    ),
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