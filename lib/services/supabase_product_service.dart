// lib/services/supabase_product_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';

class SupabaseProductService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<List<Product>> getAvailableProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_available', true);

      return (response as List)
          .map((data) => Product.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching available products: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabase.from('products').select().order('id');
      return (response as List)
          .map((data) => Product.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all products: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabase.from('products').update({
        'strain_name': product.strainName,
        'price': product.price,
        'is_available': product.isAvailable,
      }).eq('id', product.id);
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // NEW: Method to upload an image to Supabase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      final String fileName = 'product_${_uuid.v4()}.jpg';
      final String path = 'product-images/$fileName';
      await _supabase.storage.from('product-images').upload(path, imageFile);
      return _supabase.storage.from('product-images').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  // NEW: Method to update just the image URL for a product
  Future<void> updateProductImageUrl(int productId, String? imageUrl) async {
    try {
      await _supabase.from('products').update({
        'image_url': imageUrl,
      }).eq('id', productId);
    } catch (e) {
      debugPrint('Error updating product image URL: $e');
      rethrow;
    }
  }
}