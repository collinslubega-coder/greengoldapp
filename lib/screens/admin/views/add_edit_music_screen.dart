// lib/screens/admin/views/add_edit_music_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/music_service.dart';
import 'package:image_picker/image_picker.dart';

class AddEditMusicScreen extends StatefulWidget {
  final MusicTrack track;
  const AddEditMusicScreen({super.key, required this.track});

  @override
  State<AddEditMusicScreen> createState() => _AddEditMusicScreenState();
}

class _AddEditMusicScreenState extends State<AddEditMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _musicService = MusicService();
  
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  bool _isLoading = false;

  // State variables for artwork management
  File? _imageFile;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _artistController = TextEditingController(text: widget.track.artist ?? '');
    _networkImageUrl = widget.track.artworkUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }
  
  /// Picks an image from the gallery and updates the state.
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Saves changes, including uploading a new image if one was selected.
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _networkImageUrl;
      // If a new image file exists, upload it to get a new URL
      if (_imageFile != null) {
        finalImageUrl = await _musicService.uploadArtworkImage(_imageFile!);
      }
      
      await _musicService.updateTrack(
        id: widget.track.id,
        title: _titleController.text,
        artist: _artistController.text,
        artworkUrl: finalImageUrl, // Pass the final URL to the service
      );
      if (mounted) Navigator.pop(context, true); // Return true to signal a refresh
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Error updating track: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Track'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Artwork Picker
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : (_networkImageUrl != null
                            ? DecorationImage(image: NetworkImage(_networkImageUrl!), fit: BoxFit.cover)
                            : null),
                  ),
                  child: (_imageFile == null && _networkImageUrl == null)
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40),
                              SizedBox(height: 8),
                              Text("Tap to select artwork")
                            ]
                          )
                        )
                      : null,
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}