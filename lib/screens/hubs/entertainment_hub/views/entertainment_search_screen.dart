// lib/screens/hubs/entertainment_hub/views/entertainment_search_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/entertainment_service.dart';
import 'package:green_gold/screens/hubs/entertainment_hub/components/entertainment_card.dart';

class EntertainmentSearchScreen extends StatefulWidget {
  const EntertainmentSearchScreen({super.key});

  @override
  State<EntertainmentSearchScreen> createState() =>
      _EntertainmentSearchScreenState();
}

class _EntertainmentSearchScreenState extends State<EntertainmentSearchScreen> {
  final EntertainmentService _service = EntertainmentService();
  final TextEditingController _searchController = TextEditingController();
  Future<List<EntertainmentItem>>? _searchFuture;

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchFuture = _service.searchMulti(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies & TV shows...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          )
        ],
      ),
      body: _searchFuture == null
          ? const Center(
              child: Text('Start searching by typing above.'),
            )
          : FutureBuilder<List<EntertainmentItem>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('An error occurred during search.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No results found.'));
                }
                final items = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return EntertainmentCard(
                      item: item,
                      isMovie: item.isMovie,
                    );
                  },
                );
              },
            ),
    );
  }
}