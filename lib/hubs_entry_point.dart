// lib/hubs_entry_point.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/screens/login/views/password_screen.dart';
import 'package:green_gold/screens/settings/views/settings_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:green_gold/entry_point.dart';
import 'package:green_gold/screens/hubs/health_hub/views/health_hub_screen.dart';
import 'package:green_gold/screens/hubs/lifestyle_hub/views/lifestyle_hub_screen.dart';
import 'package:green_gold/screens/hubs/entertainment_hub/views/entertainment_hub_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:green_gold/services/art_service.dart';
import 'package:green_gold/components/network_image_with_loader.dart';


// --- Hubs Dashboard Screen ---
class HubsDashboardScreen extends StatefulWidget {
  const HubsDashboardScreen({super.key});

  @override
  State<HubsDashboardScreen> createState() => _HubsDashboardScreenState();
}

class _HubsDashboardScreenState extends State<HubsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Health"),
            Tab(text: "Lifestyle"),
            Tab(text: "Entertainment"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HealthHubScreen(),
              LifestyleHubScreen(),
              EntertainmentHubScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Art Gallery Screen ---
class ArtGalleryScreen extends StatefulWidget {
  const ArtGalleryScreen({super.key});

  @override
  State<ArtGalleryScreen> createState() => _ArtGalleryScreenState();
}

class _ArtGalleryScreenState extends State<ArtGalleryScreen> {
  final ArtService _artService = ArtService();
  late Future<List<Artwork>> _artworksFuture;
  final List<String> _categories = ['Abstract', 'Impressionism', 'Portraits', 'Modern', 'Nature'];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _artworksFuture = _artService.getArtworks(query: _selectedCategory);
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _artworksFuture = _artService.getArtworks(query: _selectedCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(defaultPadding / 2),
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) => _onCategorySelected(category),
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Artwork>>(
            future: _artworksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Could not load art at this time."));
              }
              final artworks = snapshot.data!;
              return MasonryGridView.builder(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: artworks.length,
                gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                itemBuilder: (context, index) {
                  final artwork = artworks[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    child: NetworkImageWithLoader(artwork.imageUrl),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


// --- Main Hubs Entry Point Widget ---
class HubsEntryPoint extends StatefulWidget {
  const HubsEntryPoint({super.key});

  @override
  State<HubsEntryPoint> createState() => _HubsEntryPointState();
}

class _HubsEntryPointState extends State<HubsEntryPoint> {
  int _pageIndex = 0;

  final List<Widget> _pages = const [
    HubsDashboardScreen(),
    ArtGalleryScreen(),
    SettingsScreen(),
  ];

  final List<String> _pageTitles = [
    "Explore Hubs",
    "My Art Gallery",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_pageTitles[_pageIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: "Enter Shop",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PasswordScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.explore_outlined, size: 30, color: Colors.white),
          Icon(Icons.palette_outlined, size: 30, color: Colors.white),
          Icon(Icons.settings_outlined, size: 30, color: Colors.white),
        ],
        color: primaryColor,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: primaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}