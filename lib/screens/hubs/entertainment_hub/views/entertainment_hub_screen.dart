// lib/screens/hubs/entertainment_hub/views/entertainment_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/services/entertainment_service.dart';
// --- FIX IS HERE: Corrected import path for the hub-specific component ---
import 'package:green_gold/screens/hubs/entertainment_hub/components/entertainment_card.dart';

class EntertainmentHubScreen extends StatefulWidget {
  const EntertainmentHubScreen({super.key});

  @override
  State<EntertainmentHubScreen> createState() => _EntertainmentHubScreenState();
}

class _EntertainmentHubScreenState extends State<EntertainmentHubScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _movieTabController;
  late TabController _tvTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _movieTabController = TabController(length: 4, vsync: this);
    _tvTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _movieTabController.dispose();
    _tvTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _mainTabController,
          tabs: const [
            Tab(text: "Movies"),
            Tab(text: "TV Shows"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            children: [
              _buildCategoryView(
                controller: _movieTabController,
                tabs: ["Popular", "Top Rated", "Upcoming", "Now Playing"],
                isMovie: true, // Pass isMovie flag
                views: [
                  _EntertainmentListView(fetchFunction: EntertainmentService().getPopularMovies, isMovie: true),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getTopRatedMovies, isMovie: true),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getUpcomingMovies, isMovie: true),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getNowPlayingMovies, isMovie: true),
                ],
              ),
              _buildCategoryView(
                controller: _tvTabController,
                tabs: ["Popular", "Top Rated", "On The Air", "Airing Today"],
                isMovie: false, // Pass isMovie flag
                views: [
                  _EntertainmentListView(fetchFunction: EntertainmentService().getPopularTvShows, isMovie: false),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getTopRatedTvShows, isMovie: false),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getOnTheAirTvShows, isMovie: false),
                  _EntertainmentListView(fetchFunction: EntertainmentService().getAiringTodayTvShows, isMovie: false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryView({
    required TabController controller,
    required List<String> tabs,
    required List<Widget> views,
    required bool isMovie,
  }) {
    return Column(
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          tabs: tabs.map((name) => Tab(text: name)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: views,
          ),
        ),
      ],
    );
  }
}

class _EntertainmentListView extends StatelessWidget {
  final Future<List<EntertainmentItem>> Function() fetchFunction;
  final bool isMovie;

  const _EntertainmentListView({
    required this.fetchFunction,
    required this.isMovie,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EntertainmentItem>>(
      future: fetchFunction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Could not load content."));
        }
        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return EntertainmentCard(item: items[index], isMovie: isMovie);
          },
        );
      },
    );
  }
}