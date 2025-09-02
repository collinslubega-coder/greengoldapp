// lib/screens/admin/views/admin_hubs_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';
import 'package:green_gold/screens/admin/views/add_edit_article_screen.dart';

class AdminHubsScreen extends StatefulWidget {
  const AdminHubsScreen({super.key});

  @override
  State<AdminHubsScreen> createState() => _AdminHubsScreenState();
}

class _AdminHubsScreenState extends State<AdminHubsScreen> {
  final ContentService _contentService = ContentService();
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _refreshArticles();
  }

  void _refreshArticles() {
    setState(() {
      _articlesFuture = _contentService.getAllArticles();
    });
  }

  void _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) {
      _refreshArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Hub Articles"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const AddEditArticleScreen()),
        tooltip: 'Add New Article',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No articles found. Tap '+' to add one."));
          }
          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                child: ListTile(
                  title: Text(
                    article.title ?? 'No Title', 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(article.hub ?? 'No Hub'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _navigateAndRefresh(AddEditArticleScreen(article: article)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}