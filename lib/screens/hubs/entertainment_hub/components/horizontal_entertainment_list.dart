// lib/screens/hubs/entertainment_hub/components/horizontal_entertainment_list.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'package:green_gold/screens/hubs/entertainment_hub/views/entertainment_detail_screen.dart';

class HorizontalEntertainmentList extends StatelessWidget {
  final Future<List<EntertainmentItem>> Function() fetchFunction;

  const HorizontalEntertainmentList({super.key, required this.fetchFunction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<List<EntertainmentItem>>(
        future: fetchFunction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No related content found."));
          }
          final items = snapshot.data!;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: defaultPadding),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntertainmentDetailScreen(
                          item: item,
                          isMovie: item.isMovie,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: NetworkImageWithLoader(item.imageUrl)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}