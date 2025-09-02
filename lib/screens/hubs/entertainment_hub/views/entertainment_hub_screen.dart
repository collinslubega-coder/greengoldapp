// lib/screens/hubs/entertainment_hub/views/entertainment_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'package:green_gold/screens/hubs/entertainment_hub/components/entertainment_card.dart';
import 'entertainment_search_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entertainment Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EntertainmentSearchScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _mainTabController,
          tabs: const [
            Tab(text: "Movies"),
            Tab(text: "TV Shows"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          // --- FIX: Correctly structured the movie view ---
          _buildCategoryView(
            controller: _movieTabController,
            tabs: ["Popular", "Top Rated", "Upcoming", "Now Playing"],
            views: [
              _EntertainmentListView(fetchFunction: EntertainmentService().getPopularMovies, isMovie: true),
              _EntertainmentListView(fetchFunction: EntertainmentService().getTopRatedMovies, isMovie: true),
              _EntertainmentListView(fetchFunction: EntertainmentService().getUpcomingMovies, isMovie: true),
              _EntertainmentListView(fetchFunction: EntertainmentService().getNowPlayingMovies, isMovie: true),
            ],
          ),
          // --- FIX: Correctly structured the TV show view ---
          _buildCategoryView(
            controller: _tvTabController,
            tabs: ["Popular", "Top Rated", "On The Air", "Airing Today"],
            views: [
              _EntertainmentListView(fetchFunction: EntertainmentService().getPopularTvShows, isMovie: false),
              _EntertainmentListView(fetchFunction: EntertainmentService().getTopRatedTvShows, isMovie: false),
              _EntertainmentListView(fetchFunction: EntertainmentService().getOnTheAirTvShows, isMovie: false),
              _EntertainmentListView(fetchFunction: EntertainmentService().getAiringTodayTvShows, isMovie: false),
            ],
          ),
        ],
      ),
    );
  }

  // --- FIX: This helper function remains the same, it was the call that was wrong ---
  Widget _buildCategoryView({
    required TabController controller,
    required List<String> tabs,
    required List<Widget> views,
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

// --- FIX: This widget also remains, the error was in the calling code ---
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