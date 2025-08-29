// lib/screens/hubs/health_hub/views/health_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';
// --- FIX IS HERE: Corrected import path for the shared component ---
import 'package:green_gold/screens/hubs/components/article_card.dart';
import 'package:green_gold/screens/hubs/article_detail/views/article_detail_screen.dart';

class HealthHubScreen extends StatefulWidget {
  const HealthHubScreen({super.key});

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen> {
  final ContentService _contentService = ContentService();
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _contentService.getArticlesByHub('Health');
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articlesFuture = _contentService.getArticlesByHub('Health');
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