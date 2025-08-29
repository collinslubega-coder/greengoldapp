// lib/components/network_image_with_loader.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final BoxFit fit;
  final double? height;
  final double? width;
  // NEW: A key to force a refresh
  final Key? key; 

  const NetworkImageWithLoader(
    this.imageUrl, {
    this.key, // Pass the key
    this.radius = 12.0,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  static const String _placeholderImagePath = 'assets/images/no_image_available.png';

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imageUrl != null && imageUrl!.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: isNetworkImage
          ? CachedNetworkImage(
              // Use the key here
              key: key, 
              imageUrl: imageUrl!,
              height: height,
              width: width,
              fit: fit,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) =>
                  Image.asset(
                    _placeholderImagePath,
                    height: height,
                    width: width,
                    fit: fit,
                  ),
            )
          : Image.asset(
              _placeholderImagePath,
              height: height,
              width: width,
              fit: fit,
            ),
    );
  }
}