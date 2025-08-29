// lib/screens/hubs/entertainment_hub/views/cast_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'entertainment_detail_screen.dart'; 

class CastDetailScreen extends StatefulWidget {
  final int personId;
  const CastDetailScreen({super.key, required this.personId});

  @override
  State<CastDetailScreen> createState() => _CastDetailScreenState();
}

class _CastDetailScreenState extends State<CastDetailScreen> {
  final EntertainmentService _service = EntertainmentService();
  late Future<ActorDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _service.getActorDetails(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ActorDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Could not load actor details."));
          }
          final actor = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 450.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(actor.name, style: const TextStyle(shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
                  background: actor.profileUrl != null 
                              ? NetworkImageWithLoader(actor.profileUrl, radius: 0)
                              : Container(color: Colors.black26),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Biography", style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: defaultPadding / 2),
                              Text(actor.biography ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding * 2),
                      if (actor.knownFor.isNotEmpty) ...[
                        Text("Known For", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: actor.knownFor.length,
                            separatorBuilder: (context, index) => const SizedBox(width: defaultPadding),
                            itemBuilder: (context, index) {
                              final item = actor.knownFor[index];
                              return SizedBox(
                                width: 150,
                                child: InkWell(
                                  onTap: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EntertainmentDetailScreen(item: item, isMovie: true),
                                      ),
                                    );
                                  },
                                  child: NetworkImageWithLoader(item.imageUrl)
                                ),
                              );
                            },
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}