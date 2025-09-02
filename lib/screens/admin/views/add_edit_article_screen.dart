// lib/screens/admin/views/add_edit_article_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';
import 'package:image_picker/image_picker.dart';

class AddEditArticleScreen extends StatefulWidget {
  final Article? article;
  const AddEditArticleScreen({super.key, this.article});

  @override
  State<AddEditArticleScreen> createState() => _AddEditArticleScreenState();
}

class _AddEditArticleScreenState extends State<AddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentService = ContentService();
  bool get _isEditing => widget.article != null;

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _bodyController;
  late TextEditingController _sourcesController; // NEW: Controller for sources
  String? _selectedHub;
  bool _isLoading = false;

  File? _selectedImage;
  String? _imageUrlFromEdit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? '');
    _bodyController = TextEditingController(text: widget.article?.body ?? '');
    // NEW: Initialize sources controller by joining the list with newlines
    _sourcesController = TextEditingController(
      text: widget.article?.sources?.join('\n') ?? '',
    );
    _selectedHub = widget.article?.hub;
    _imageUrlFromEdit = widget.article?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _bodyController.dispose();
    _sourcesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Failed to pick image: $e");
      }
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      try {
        imageUrl = await _contentService.uploadImage(_selectedImage!);
      } catch (e) {
        if (mounted) {
          showErrorSnackBar(context, "Error uploading image: $e");
          setState(() => _isLoading = false);
        }
        return;
      }
    } else {
      imageUrl = _imageUrlFromEdit;
    }

    final newArticle = Article(
      id: widget.article?.id ?? 0,
      title: _titleController.text,
      hub: _selectedHub!,
      category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
      imageUrl: imageUrl,
      body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
      // NEW: Split the sources text field into a list of strings
      sources: _sourcesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
      createdAt: widget.article?.createdAt ?? DateTime.now(),
    );

    try {
      await _contentService.saveArticle(newArticle);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Error saving article: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteArticle() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article?'),
        content: const Text('This action cannot be undone.'),
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
      setState(() => _isLoading = true);
      try {
        await _contentService.deleteArticle(widget.article!.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) showErrorSnackBar(context, "Error deleting: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Article' : 'Add Article'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: errorColor),
              onPressed: _isLoading ? null : _deleteArticle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => (value == null || value.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: defaultPadding),
              DropdownButtonFormField<String>(
                value: _selectedHub,
                decoration: const InputDecoration(labelText: 'Hub'),
                items: ['Health', 'Lifestyle', 'Entertainment']
                    .map((hub) => DropdownMenuItem(value: hub, child: Text(hub)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedHub = value),
                validator: (value) => (value == null) ? 'Hub is required' : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category (e.g., Fashion)'),
              ),
              const SizedBox(height: defaultPadding),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : (_imageUrlFromEdit != null && _imageUrlFromEdit!.isNotEmpty)
                          ? Image.network(_imageUrlFromEdit!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text('Tap to upload image', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body Content', alignLabelWithHint: true),
                maxLines: 10,
              ),
              const SizedBox(height: defaultPadding),
              // NEW: Add the text field for sources
              TextFormField(
                controller: _sourcesController,
                decoration: const InputDecoration(
                  labelText: 'Sources (one per line)',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveArticle,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}