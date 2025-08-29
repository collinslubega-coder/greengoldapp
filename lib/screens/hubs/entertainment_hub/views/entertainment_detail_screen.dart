// lib/screens/hubs/entertainment_hub/views/entertainment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'package:green_gold/screens/hubs/components/cast_card.dart';
import '../components/vibe_score_display.dart';

class EntertainmentDetailScreen extends StatefulWidget {
  final EntertainmentItem item;
  final bool isMovie;
  const EntertainmentDetailScreen({super.key, required this.item, required this.isMovie});

  @override
  State<EntertainmentDetailScreen> createState() => _EntertainmentDetailScreenState();
}

class _EntertainmentDetailScreenState extends State<EntertainmentDetailScreen> {
  final EntertainmentService _service = EntertainmentService();
  late Future<List<CastMember>> _castFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isMovie) {
      _castFuture = _service.getMovieCast(widget.item.id);
    } else {
      _castFuture = _service.getTvShowCast(widget.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450.0,
            pinned: true,
            // --- FIX IS HERE: No title property is set ---
            flexibleSpace: FlexibleSpaceBar(
              background: NetworkImageWithLoader(widget.item.imageUrl, radius: 0),
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
                           Text(
                            widget.item.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (widget.item.subtitle != null && widget.item.subtitle!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                widget.item.subtitle!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: defaultPadding / 2),
                          VibeScoreDisplay(
                            voteAverage: widget.item.voteAverage,
                            voteCount: widget.item.voteCount,
                          ),
                          const Divider(height: defaultPadding * 2),
                          Text(
                            "Overview",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          Text(
                            widget.item.overview,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  Text(
                    "Cast & Crew",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 220,
                    child: FutureBuilder<List<CastMember>>(
                      future: _castFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("Cast information not available."));
                        }
                        final cast = snapshot.data!;
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length,
                          separatorBuilder: (context, index) => const SizedBox(width: defaultPadding),
                          itemBuilder: (context, index) {
                            final castMember = cast[index];
                            return CastCard(
                              castMember: castMember,
                              onTap: () {
                                Navigator.pushNamed(
                                  context, 
                                  castDetailScreenRoute, 
                                  arguments: castMember.id
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}