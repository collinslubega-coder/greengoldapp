// lib/screens/admin/views/admin_music_screen.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/music_service.dart';
import 'package:green_gold/screens/admin/views/add_edit_music_screen.dart';
import 'package:green_gold/components/network_image_with_loader.dart';

class AdminMusicScreen extends StatefulWidget {
  const AdminMusicScreen({super.key});

  @override
  State<AdminMusicScreen> createState() => _AdminMusicScreenState();
}

class _AdminMusicScreenState extends State<AdminMusicScreen> {
  final MusicService _musicService = MusicService();
  late Future<List<MusicTrack>> _tracksFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _refreshTracks();
  }

  void _refreshTracks() {
    if (mounted) {
      setState(() {
        _tracksFuture = _musicService.getAllTracks();
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    // ... (code for this method remains unchanged)
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        _showUploadDialog(file);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Failed to open file picker: $e");
    }
  }

  void _showUploadDialog(File file) {
    // ... (code for this method remains unchanged)
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final scaffoldContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upload New Track'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setState(() => _isUploading = true);
                Navigator.pop(dialogContext); 
                
                try {
                  await _musicService.uploadTrack(
                    file: file,
                    title: titleController.text,
                    artist: artistController.text,
                  );
                } catch (e) {
                  if (mounted) showErrorSnackBar(scaffoldContext, "Upload failed: $e");
                } finally {
                  if (mounted) {
                    setState(() => _isUploading = false);
                    _refreshTracks();
                  }
                }
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(MusicTrack track) async {
    // ... (code for this method remains unchanged)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Track?'),
        content: Text('Are you sure you want to delete "${track.title}"? This cannot be undone.'),
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
      try {
        await _musicService.deleteTrack(track);
        _refreshTracks();
      } catch (e) {
        if (mounted) showErrorSnackBar(context, "Delete failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ** THE FIX IS HERE **
      appBar: AppBar(title: const Text("Manage Vibe Playlist")),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        tooltip: 'Upload Track',
        backgroundColor: _isUploading ? Colors.grey : Theme.of(context).primaryColor,
        child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.upload),
      ),
      body: FutureBuilder<List<MusicTrack>>(
        future: _tracksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No music tracks uploaded."));
          }
          final tracks = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshTracks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: NetworkImageWithLoader(track.artworkUrl, radius: 4),
                    ),
                    title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(track.artist ?? 'No Artist'),
                    trailing: Switch(
                      value: track.isActive,
                      onChanged: (bool value) async {
                        await _musicService.toggleTrackActivity(track.id);
                        _refreshTracks();
                      },
                    ),
                    onTap: () async {
                      final refreshed = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEditMusicScreen(track: track)),
                      );
                      if (refreshed == true) {
                        _refreshTracks();
                      }
                    },
                    onLongPress: () => _confirmAndDelete(track),
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