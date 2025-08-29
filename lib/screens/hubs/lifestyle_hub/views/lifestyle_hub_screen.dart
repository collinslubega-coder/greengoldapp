// lib/screens/hubs/lifestyle_hub/views/lifestyle_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';
// --- FIX IS HERE: Corrected import path for the shared component ---
import 'package:green_gold/screens/hubs/components/article_card.dart';
import 'package:green_gold/screens/hubs/article_detail/views/article_detail_screen.dart';

class LifestyleHubScreen extends StatefulWidget {
  const LifestyleHubScreen({super.key});

  @override
  State<LifestyleHubScreen> createState() => _LifestyleHubScreenState();
}

class _LifestyleHubScreenState extends State<LifestyleHubScreen> {
  final ContentService _contentService = ContentService();
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _contentService.getArticlesByHub('Lifestyle');
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articlesFuture = _contentService.getArticlesByHub('Lifestyle');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No articles found in this hub yet."));
        }
        
        final articles = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: _refreshArticles,
          child: ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleCard(
                article: article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}