// lib/services/settings_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, String> _settings = {};
  bool _isLoading = true;

  Map<String, String> get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsService() {
    initializeSettings();
  }

  /// Fetches all settings from Supabase and stores them in memory.
  Future<void> initializeSettings() async {
    // ** THE FIX IS HERE: The check that prevented re-fetching has been removed. **
    // This ensures that settings are always fetched from the server when this method is called.
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabase.from('settings').select('key, value');
      final fetchedSettings = <String, String>{};
      for (final item in response as List) {
        fetchedSettings[item['key']] = item['value'] as String? ?? '';
      }
      _settings = fetchedSettings;
    } catch (e) {
      debugPrint('Error fetching all settings: $e');
      _settings = {}; // Reset on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves settings and provides an instant UI update.
  Future<void> saveSettings(Map<String, String> settingsToSave) async {
    try {
      // 1. Update the local state immediately for a fast UI response.
      _settings.addAll(settingsToSave);
      notifyListeners();

      // 2. Save the data to Supabase in the background.
      final List<Map<String, String>> records = settingsToSave.entries
          .map((entry) => {'key': entry.key, 'value': entry.value})
          .toList();
      await _supabase.from('settings').upsert(records, onConflict: 'key');
      
    } catch (e) {
      debugPrint('Error saving settings: $e');
      // If saving fails, reload from the server to ensure data consistency.
      await initializeSettings(); 
      rethrow;
    }
  }
  
  /// Deletes a setting and provides an instant UI update.
  Future<void> deleteSetting(String key) async {
    try {
      // 1. Optimistically remove the key for a fast UI response.
      _settings.remove(key);
      notifyListeners();

      // 2. Perform the delete operation on the server.
      await _supabase.from('settings').delete().eq('key', key);

    } catch (e) {
      debugPrint('Error deleting setting: $e');
      // If deleting fails, reload to restore the correct state.
      await initializeSettings();
      rethrow;
    }
  }
}
