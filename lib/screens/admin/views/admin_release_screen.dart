// lib/screens/admin/views/admin_release_screen.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReleaseScreen extends StatefulWidget {
  const AdminReleaseScreen({super.key});

  @override
  State<AdminReleaseScreen> createState() => _AdminReleaseScreenState();
}

class _AdminReleaseScreenState extends State<AdminReleaseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _versionController;
  late TextEditingController _notesController;
  
  File? _selectedApk;
  String? _selectedApkName;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _currentApkLink;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  /// Load existing values from SettingsService into controllers
  void _loadCurrentSettings() {
    final settings = Provider.of<SettingsService>(context, listen: false).settings;
    _versionController = TextEditingController(text: settings['latest_app_version'] ?? '');
    _notesController = TextEditingController(text: settings['latest_release_notes'] ?? '');
    _currentApkLink = settings['android_apk_link'];
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _versionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Use FilePicker to select an .apk file
  Future<void> _pickApk() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'], // Ensure only APK files can be picked
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedApk = File(result.files.single.path!);
          _selectedApkName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Failed to pick APK: $e");
    }
  }

  /// Upload the file to Supabase Storage
  Future<String> _uploadApkToStorage(File apkFile, String version) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = 'greengold-v$version.apk';
      // We upload to a 'releases' bucket. This must be created in Supabase.
      final path = '$fileName'; 
      
      await supabase.storage
          .from('releases') // BUCKET NAME
          .upload(
            path, 
            apkFile,
            fileOptions: const FileOptions(upsert: true), // Overwrite if same version exists
          );
          
      // Return the public URL
      return supabase.storage.from('releases').getPublicUrl(path);

    } catch (e) {
      debugPrint("Error uploading APK: $e");
      rethrow;
    }
  }

  /// Main publish logic
  Future<void> _publishUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    
    // An APK must be selected *or* one must already exist
    if (_selectedApk == null && (_currentApkLink == null || _currentApkLink!.isEmpty)) {
      showErrorSnackBar(context, "You must select an APK file to publish a new release.");
      return;
    }

    setState(() => _isUploading = true);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final newVersion = _versionController.text;
    
    try {
      final Map<String, String> settingsToSave = {
        'latest_app_version': newVersion,
        'latest_release_notes': _notesController.text,
      };

      // Only upload a new APK and update the link if a new file was selected
      if (_selectedApk != null) {
        final newApkUrl = await _uploadApkToStorage(_selectedApk!, newVersion);
        settingsToSave['android_apk_link'] = newApkUrl;
      }

      await settingsService.saveSettings(settingsToSave);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Release published successfully!'),
          backgroundColor: successColor,
        ),
      );
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Failed to publish release: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage App Release"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _versionController,
                      decoration: const InputDecoration(
                        labelText: "Latest Version Number",
                        hintText: "e.g., 1.0.3",
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Version is required" : null,
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: "Release Notes",
                        hintText: "• New feature\n• Bug fix",
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                      validator: (v) => (v == null || v.isEmpty) ? "Notes are required" : null,
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    Text("Upload Android APK", style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: defaultPadding / 2),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Select .APK File"),
                      onPressed: _pickApk,
                    ),
                    if (_selectedApkName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Selected: $_selectedApkName", style: const TextStyle(color: successColor)),
                      )
                    else if (_currentApkLink != null)
                       Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Current file linked. Select a new file to replace it.", style: Theme.of(context).textTheme.bodySmall),
                      ),
                    
                    const SizedBox(height: defaultPadding * 2),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _publishUpdate,
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Publish Update"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}