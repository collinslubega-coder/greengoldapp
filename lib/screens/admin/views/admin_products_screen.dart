// lib/screens/admin/views/admin_products_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:green_gold/services/supabase_product_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final SupabaseProductService _productService = SupabaseProductService();
  final ImagePicker _picker = ImagePicker();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getAllProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getAllProducts();
    });
  }

  Future<void> _pickAndUploadImage(Product product) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      try {
        final imageUrl = await _productService.uploadImage(imageFile);
        await _productService.updateProductImageUrl(product.id, imageUrl);
        _refreshProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e'), backgroundColor: errorColor),
          );
        }
      }
    }
  }

  Future<void> _removeImage(Product product) async {
    try {
      await _productService.updateProductImageUrl(product.id, null);
      _refreshProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove image: $e'), backgroundColor: errorColor),
        );
      }
    }
  }

  void _showEditDialog(Product product) {
    final isFlower = product.category == 'Flowers';
    final nameController = TextEditingController(text: product.strainName ?? '');
    final priceController = TextEditingController(text: product.price?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit ${product.strainName ?? product.category}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFlower)
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Strain Name"),
                  )
                else
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: defaultPadding),
                Text("Manage Image", style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload"),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickAndUploadImage(product);
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: errorColor),
                      label: const Text("Remove", style: TextStyle(color: errorColor)),
                      onPressed: product.imageUrl == null ? null : () {
                        Navigator.pop(context);
                        _removeImage(product);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedProduct = Product(
                  id: product.id,
                  category: product.category,
                  isAvailable: product.isAvailable,
                  strainName: isFlower ? nameController.text : product.strainName,
                  price: isFlower ? product.price : double.tryParse(priceController.text),
                  type: product.type,
                  generation: product.generation,
                  imageUrl: product.imageUrl,
                );
                await _productService.updateProduct(updatedProduct);
                Navigator.pop(context);
                _refreshProducts();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- FIX IS HERE ---
      appBar: AppBar(
        title: const Text("Manage Products"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshProducts(),
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No products found in the database."));
            }
            final products = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isFlower = product.category == 'Flowers';
                String title = isFlower
                    ? "${product.type} - ${product.generation}"
                    : product.strainName ?? 'Unnamed Product';
                String subtitle = isFlower
                    ? "Strain: ${product.strainName}"
                    : "Category: ${product.category}";

                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: NetworkImageWithLoader(
                        product.imageUrl,
                        key: ValueKey(product.imageUrl ?? DateTime.now().toIso8601String()),
                        radius: 4,
                      ),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitle),
                    trailing: Switch(
                      value: product.isAvailable,
                      onChanged: (value) async {
                        final updatedProduct = Product(
                          id: product.id,
                          category: product.category,
                          isAvailable: value,
                          strainName: product.strainName,
                          price: product.price,
                          type: product.type,
                          generation: product.generation,
                          imageUrl: product.imageUrl,
                        );
                        await _productService.updateProduct(updatedProduct);
                        _refreshProducts();
                      },
                    ),
                    onTap: () => _showEditDialog(product),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}