// lib/screens/admin/views/add_edit_setting_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:provider/provider.dart';

class AddEditSettingScreen extends StatefulWidget {
  final MapEntry<String, String>? setting;

  const AddEditSettingScreen({super.key, this.setting});

  @override
  State<AddEditSettingScreen> createState() => _AddEditSettingScreenState();
}

class _AddEditSettingScreenState extends State<AddEditSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  bool _isLoading = false;
  bool get _isEditing => widget.setting != null;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.setting?.key ?? '');
    _valueController = TextEditingController(text: widget.setting?.value ?? '');
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveSetting() async {
    if (!_formKey.currentState!.validate()) return;
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final settingsService = Provider.of<SettingsService>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final key = _keyController.text;
      final value = _valueController.text;

      await settingsService.saveSettings({key: value});

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Setting saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);

    } catch (e) {
      if (mounted) {
        showErrorSnackBar(scaffoldMessenger.context, "Failed to save setting: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Setting' : 'Add New Setting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _keyController,
                readOnly: _isEditing, // Key cannot be changed when editing
                decoration: const InputDecoration(
                  labelText: "Setting Key",
                  hintText: "e.g., tiktok_link (no spaces)",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a key';
                  if (value.contains(' ')) return 'Key cannot contain spaces';
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: "Setting Value",
                  hintText: "e.g., https://tiktok.com/@yourprofile",
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a value';
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSetting,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Setting"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}