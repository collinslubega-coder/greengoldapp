// lib/services/content_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for a single article
class Article {
  final int id;
  final String title;
  final String hub;
  final String? category;
  final String? imageUrl;
  final String? body;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.hub,
    this.category,
    this.imageUrl,
    this.body,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      hub: json['hub'],
      category: json['category'],
      imageUrl: json['image_url'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Service to fetch articles from Supabase
class ContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Article>> getArticlesByHub(String hubName) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .eq('hub', hubName)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((data) => Article.fromJson(data))
          .toList();

    } catch (e) {
      debugPrint('Error fetching articles for hub $hubName: $e');
      rethrow;
    }
  }

  // ** NEW: Get all articles for admin view **
  Future<List<Article>> getAllArticles() async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => Article.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all articles: $e');
      rethrow;
    }
  }

  // ** NEW: Create or Update an article **
  Future<void> saveArticle(Article article) async {
    final data = {
      'title': article.title,
      'hub': article.hub,
      'category': article.category,
      'image_url': article.imageUrl,
      'body': article.body,
    };
    try {
      if (article.id == 0) { // New article
        await _supabase.from('articles').insert(data);
      } else { // Existing article
        await _supabase.from('articles').update(data).eq('id', article.id);
      }
    } catch (e) {
      debugPrint('Error saving article: $e');
      rethrow;
    }
  }

  // ** NEW: Delete an article **
  Future<void> deleteArticle(int articleId) async {
    try {
      await _supabase.from('articles').delete().eq('id', articleId);
    } catch (e) {
      debugPrint('Error deleting article: $e');
      rethrow;
    }
  }
}