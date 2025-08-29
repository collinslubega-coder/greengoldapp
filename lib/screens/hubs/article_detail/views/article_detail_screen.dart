// lib/screens/hubs/article_detail/views/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/content_service.dart';
import 'package:intl/intl.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // This SliverAppBar creates the collapsing header effect
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            // --- FIX IS HERE: No title property is set ---
            flexibleSpace: FlexibleSpaceBar(
              background: article.imageUrl != null
                  ? NetworkImageWithLoader(article.imageUrl, radius: 0)
                  : Container(color: Colors.black26),
            ),
          ),
          // This sliver contains the rest of the page content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        "Published on ${DateFormat.yMMMd().format(article.createdAt)}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: defaultPadding * 2),
                      Text(
                        article.body ?? "No content available.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}