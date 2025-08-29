// lib/screens/admin/views/admin_lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:green_gold/screens/admin/views/contact_settings_screen.dart';

// Import screens for navigation
import 'package:green_gold/screens/admin/views/admin_hubs_screen.dart';
import 'package:green_gold/screens/admin/views/admin_music_screen.dart';
import 'package:green_gold/screens/admin/views/admin_orders_screen.dart';
import 'package:green_gold/screens/admin/views/admin_products_screen.dart';


class AdminLobbyScreen extends StatefulWidget {
  const AdminLobbyScreen({super.key});

  @override
  State<AdminLobbyScreen> createState() => _AdminLobbyScreenState();
}

class _AdminLobbyScreenState extends State<AdminLobbyScreen> {
  late Future<Map<String, dynamic>> _lobbyDataFuture;

  @override
  void initState() {
    super.initState();
    _lobbyDataFuture = _fetchLobbyData();
  }

  Future<Map<String, dynamic>> _fetchLobbyData() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    
    await userDataService.refreshOrders();
    final allOrders = userDataService.orders;
    
    final pendingOrders = allOrders.where((o) => !o.isCompleted).length;

    return {
      'pendingOrdersCount': pendingOrders,
      'processingOrdersCount': 0, // Placeholder for future logic
    };
  }

  void _refreshData() {
    setState(() {
      _lobbyDataFuture = _fetchLobbyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _lobbyDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error loading lobby data: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No data available."));
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserDataService>(
                    builder: (context, userDataService, child) {
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: primaryColor,
                                child: Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: defaultPadding),
                              Text(
                                "Hello, ${userDataService.userName ?? 'Admin'}",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: defaultPadding * 2),

                  Text("Orders Overview", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: defaultPadding),
                  _buildMetricRow([
                    _MetricCardData("Pending Orders", data['pendingOrdersCount'].toString(), Icons.pending_actions, warningColor),
                    _MetricCardData("Processing", data['processingOrdersCount'].toString(), Icons.local_shipping, Colors.blueAccent),
                  ]),
                  const SizedBox(height: defaultPadding),
                   _ActionCard(
                    title: "Manage All Orders",
                    icon: Icons.receipt_long,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersScreen())),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  
                  Text("Content & Store", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: defaultPadding),
                  _ActionCard(
                    title: "Manage Products",
                    icon: Icons.store_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductsScreen())),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                   _ActionCard(
                    title: "Manage Hub Articles",
                    icon: Icons.article_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHubsScreen())),
                  ),
                   const SizedBox(height: defaultPadding / 2),
                   _ActionCard(
                    title: "Manage Vibe Playlist",
                    icon: Icons.music_note_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMusicScreen())),
                  ),

                  const SizedBox(height: defaultPadding * 2),
                  Text("Store & Operations", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: defaultPadding / 2),
                  _ActionCard(
                    title: "Contact & Link Settings",
                    icon: Icons.link,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactSettingsScreen())),
                  ),

                  const SizedBox(height: kToolbarHeight + defaultPadding),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildMetricRow(List<_MetricCardData> cards) {
    return Row(
      children: cards.map((data) => Expanded(
        child: MetricCard(
          title: data.title,
          value: data.value,
          icon: data.icon,
          color: data.color,
        ),
      )).expand((widget) => [widget, const SizedBox(width: defaultPadding)]).toList()..removeLast(),
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _MetricCardData(this.title, this.value, this.icon, this.color);
}

class MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: defaultPadding / 2),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: defaultPadding/2),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}