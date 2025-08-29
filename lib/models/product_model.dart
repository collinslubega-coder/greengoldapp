// lib/models/product_model.dart

class Product {
  final int id;
  final String category;
  final String? type;
  final String? generation;
  final String? strainName;
  final double? price;
  final bool isAvailable;
  final String? imageUrl;

  Product({
    required this.id,
    required this.category,
    this.type,
    this.generation,
    this.strainName,
    this.price,
    required this.isAvailable,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      category: json['category'] as String,
      type: json['type'] as String?,
      generation: json['generation'] as String?,
      strainName: json['strain_name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'generation': generation,
      'strain_name': strainName,
      'price': price,
      'is_available': isAvailable,
      'image_url': imageUrl,
    };
  }
}