// lib/screens/home/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/product/new_product_card.dart';
import 'package:green_gold/components/product/new_product_card_skeleton.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/supabase_product_service.dart';
import 'package:collection/collection.dart'; // Import collection package
import 'components/explore_banner_card.dart';
import 'components/home_category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseProductService _service = SupabaseProductService();
  late Future<List<Product>> _productsFuture;

  final List<String> _categories = ["Flowers", "Ointments", "Edibles"];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _productsFuture = _service.getAvailableProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _service.getAvailableProducts();
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: ExploreBannerCard()),
              HomeCategoryFilter(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected),
              const SizedBox(height: defaultPadding),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingSkeleton();
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildLoadingSkeleton(isError: true);
                    }

                    final allProducts = snapshot.data!;
                    
                    final filteredProducts = allProducts.where((p) {
                      if (_selectedCategory == "Flowers") {
                        return p.category == "Flowers";
                      } else {
                        return p.category == _selectedCategory;
                      }
                    }).toList();

                    // === THE ONLY CHANGE IS HERE ===
                    // This block checks if the filtered list for the selected category is empty.
                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Text(
                            "No products found in the '$_selectedCategory' category.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }
                    // === END OF CHANGE ===

                    if (_selectedCategory == "Flowers") {
                      final flowerTypes = {
                        for (var p in filteredProducts) p.type
                      }.toList();

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                        itemCount: flowerTypes.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                        ),
                        itemBuilder: (context, index) {
                          final type = flowerTypes[index];
                          // FIX: Intentionally find the '1st Gen' product to use its image as the category thumbnail.
                          final productForType = filteredProducts.firstWhereOrNull(
                            (p) => p.type == type && p.generation == '1st Gen'
                          ) ?? filteredProducts.firstWhere((p) => p.type == type); // Fallback to first available

                          return NewProductCard(
                            productName: "$type Flowers", 
                            imageUrl: productForType.imageUrl,
                            press: () {
                              Navigator.pushNamed(
                                context,
                                groupedProductDetailsScreenRoute,
                                arguments: filteredProducts.where((p) => p.type == type).toList(),
                              );
                            },
                          );
                        },
                      );
                    } else {
                       return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                        itemCount: filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return NewProductCard(
                            productName: product.strainName ?? 'Unnamed',
                            imageUrl: product.imageUrl,
                            press: () {
                              Navigator.pushNamed(
                                context, 
                                groupedProductDetailsScreenRoute, 
                                arguments: [product]
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton({bool isError = false}) {
    // This function remains unchanged
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
         if (isError)
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
                  const SizedBox(height: defaultPadding),
                  const Text("Unable to Connect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: defaultPadding / 2),
                  const Text("Please check your internet connection and pull down to refresh.", textAlign: TextAlign.center),
                ],
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              childAspectRatio: 0.7,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
            ),
            itemBuilder: (context, index) => const NewProductCardSkeleton(),
          ),
        ],
      ),
    );
  }
}