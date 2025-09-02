// lib/screens/hubs/entertainment_hub/components/entertainment_card.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'package:green_gold/screens/hubs/entertainment_hub/views/entertainment_detail_screen.dart';

class EntertainmentCard extends StatelessWidget {
  final EntertainmentItem item;
  final bool isMovie;

  const EntertainmentCard({super.key, required this.item, required this.isMovie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntertainmentDetailScreen(item: item, isMovie: isMovie),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: NetworkImageWithLoader(item.imageUrl, radius: 0),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const Divider(height: defaultPadding),
                    Text(
                      item.overview,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // New "Read More" button
                    const SizedBox(height: defaultPadding / 2),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntertainmentDetailScreen(item: item, isMovie: isMovie),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text(
                        'Read More',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}