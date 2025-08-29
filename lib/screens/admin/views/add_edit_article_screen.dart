// lib/screens/admin/views/add_edit_article_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/custom_error_snackbar.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';

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
  late TextEditingController _imageUrlController;
  late TextEditingController _bodyController;
  String? _selectedHub;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? '');
    _imageUrlController = TextEditingController(text: widget.article?.imageUrl ?? '');
    _bodyController = TextEditingController(text: widget.article?.body ?? '');
    _selectedHub = widget.article?.hub;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newArticle = Article(
      id: widget.article?.id ?? 0,
      title: _titleController.text,
      hub: _selectedHub!,
      category: _categoryController.text,
      imageUrl: _imageUrlController.text,
      body: _bodyController.text,
      createdAt: widget.article?.createdAt ?? DateTime.now(),
    );

    try {
      await _contentService.saveArticle(newArticle);
      if (mounted) {
        Navigator.pop(context, true); // Return true to signal a refresh
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
          Navigator.pop(context, true); // Pop twice to go back to the list
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
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body Content', alignLabelWithHint: true),
                maxLines: 10,
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