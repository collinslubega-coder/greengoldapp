// lib/services/art_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for a single piece of art
class Artwork {
  final int id;
  final String title;
  final String? artist;
  final String imageUrl;

  Artwork({
    required this.id,
    required this.title,
    this.artist,
    required this.imageUrl,
  });

  factory Artwork.fromJson(Map<String, dynamic> json, String imageBaseUrl) {
    final imageId = json['image_id'];
    return Artwork(
      id: json['id'],
      title: json['title'],
      artist: json['artist_display']?.split('\n').first ?? 'Unknown Artist',
      imageUrl: '$imageBaseUrl/$imageId/full/843,/0/default.jpg',
    );
  }
}

// Service to fetch art from the Art Institute of Chicago API
class ArtService {
  final String _baseUrl = 'https://api.artic.edu/api/v1/artworks';

  Future<List<Artwork>> getArtworks({String query = 'impressionism', int limit = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query&limit=$limit&fields=id,title,image_id,artist_display'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageBaseUrl = data['config']['iiif_url'];
        final artworksData = data['data'] as List;

        // Filter out artworks that don't have an image
        return artworksData
            .where((item) => item['image_id'] != null)
            .map((item) => Artwork.fromJson(item, imageBaseUrl))
            .toList();
      } else {
        throw Exception('Failed to load artworks');
      }
    } catch (e) {
      debugPrint('Error fetching artworks: $e');
      rethrow;
    }
  }
}