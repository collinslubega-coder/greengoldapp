// lib/screens/product/views/grouped_product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/cart_button.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/product_model.dart';
import 'package:green_gold/services/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class GroupedProductDetailScreen extends StatefulWidget {
  final List<Product> products;
  const GroupedProductDetailScreen({super.key, required this.products});

  @override
  State<GroupedProductDetailScreen> createState() =>
      _GroupedProductDetailScreenState();
}

class _GroupedProductDetailScreenState
    extends State<GroupedProductDetailScreen> {
  String? _selectedGeneration;
  String? _selectedForm;
  Product? _selectedProduct;
  int _quantity = 1;

  bool get _isProductAvailable => widget.products.isNotEmpty;
  bool get _isFlowerProduct => _isProductAvailable && widget.products.first.category == 'Flowers';

  @override
  void initState() {
    super.initState();
    if (_isProductAvailable) {
      if (_isFlowerProduct) {
        _selectedGeneration = widget.products.first.generation;
        _selectedProduct = widget.products.firstWhereOrNull(
          (p) => p.generation == _selectedGeneration,
        );
      } else {
        _selectedProduct = widget.products.first;
      }
    }
  }

  // Method to show the "Added to Cart" modal sheet
  void _showAddedToCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use a themed color
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Added to Cart", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                Navigator.pop(context); // Close the modal sheet
                Navigator.pushNamed(context, 'cartScreenRoute'); // Correct route name
              },
              child: const Text("Go to Cart"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProductAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text("Unavailable")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              "There are no products currently available for this category.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    
    final product = _selectedProduct ?? widget.products.first;
    final currencyFormatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX ');
    final price = product.price ?? 0.0;
    final totalPrice = price * _quantity;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.products.first.type ?? product.strainName ?? "Product"),
      ),
      bottomNavigationBar: CartButton(
        price: totalPrice,
        press: () {
            if (_isFlowerProduct && _selectedForm == null) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an option (Bud or Pre-roll).'), backgroundColor: warningColor),
                );
                return;
            }
            final cartService = Provider.of<CartService>(context, listen: false);
            cartService.addItem(product, _quantity, selectedForm: _selectedForm);

            // Replace the SnackBar with the new modal sheet
            _showAddedToCartSheet(context);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          SizedBox(
            height: 250,
            child: NetworkImageWithLoader(product.imageUrl, radius: 16),
          ),
          
          // --- NEW: Disclaimer is added here ---
          if (_isFlowerProduct)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Image is for illustrative purposes only. Product is sold per gram/joint.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),

          const SizedBox(height: defaultPadding),

          if (_isFlowerProduct) ...[
            Text("Selected Strain: ${product.strainName}", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),

            Text(currencyFormatter.format(price), style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: defaultPadding * 2),

            Text("Select Generation", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: widget.products.map((p) => p.generation!).toSet().toList().map((gen) => ChoiceChip(
                label: Text(gen),
                selected: _selectedGeneration == gen,
                onSelected: (selected) {
                  setState(() {
                    _selectedGeneration = gen;
                    _selectedProduct = widget.products.firstWhereOrNull(
                      (p) => p.generation == _selectedGeneration,
                    );
                    _quantity = 1;
                  });
                },
              )).toList(),
            ),
            const Divider(height: defaultPadding * 2),

            Text("Select Option", style: Theme.of(context).textTheme.titleMedium),
             ...['Bud', 'Pre-roll'].map((form) => RadioListTile<String>(
              title: Text(form),
              value: form,
              groupValue: _selectedForm,
              onChanged: (value) => setState(() => _selectedForm = value),
            )),
          ] else ... [
             Text(product.strainName ?? '', style: Theme.of(context).textTheme.headlineSmall),
             const SizedBox(height: 8),
             Text(currencyFormatter.format(price), style: Theme.of(context).textTheme.titleLarge),
          ],

          const Divider(height: defaultPadding * 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Quantity", style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Text('$_quantity', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _quantity++)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}