// lib/services/content_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for a single article
class Article {
  final int id;
  final String? title;
  final String? hub;
  final String? category;
  final String? imageUrl;
  final String? body;
  final List<String>? sources; // NEW: Added sources field
  final DateTime createdAt;

  Article({
    required this.id,
    this.title,
    this.hub,
    this.category,
    this.imageUrl,
    this.body,
    this.sources, // NEW: Added sources parameter
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] as String?,
      hub: json['hub'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      body: json['body'] as String?,
      // NEW: Handle sources from JSON, ensure it's a List<String>
      sources: (json['sources'] is List) 
          ? List<String>.from(json['sources']) 
          : null,
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

  Future<void> saveArticle(Article article) async {
    final data = {
      'title': article.title,
      'hub': article.hub,
      'category': article.category,
      'image_url': article.imageUrl,
      'body': article.body,
      'sources': article.sources, // NEW: Include sources in the data to be saved
    };
    try {
      if (article.id == 0) {
        await _supabase.from('articles').insert(data);
      } else {
        await _supabase.from('articles').update(data).eq('id', article.id);
      }
    } catch (e) {
      debugPrint('Error saving article: $e');
      rethrow;
    }
  }

  Future<void> deleteArticle(int articleId) async {
    try {
      await _supabase.from('articles').delete().eq('id', articleId);
    } catch (e) {
      debugPrint('Error deleting article: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'articles/$fileName';

      await _supabase.storage
          .from('article_images')
          .upload(path, imageFile);

      final String publicUrl = _supabase.storage
          .from('article_images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }
}