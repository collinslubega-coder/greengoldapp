// lib/screens/profile/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/route/route_constants.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:green_gold/screens/profile/views/components/featured_track_player.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Lobby"),
        centerTitle: true,
      ),
      body: Consumer<UserDataService>(
        builder: (context, userDataService, child) {
          final bool hasMadePurchase = userDataService.orders.isNotEmpty;
          final String displayName = (hasMadePurchase &&
                  userDataService.userName != null &&
                  userDataService.userName!.isNotEmpty)
              ? userDataService.userName!
              : "Guest User";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                // User Info Card
                Card(
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
                          child:
                              Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: defaultPadding),
                        Text(
                          "Hello $displayName",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Featured Track Player
                const FeaturedTrackPlayer(),

                const SizedBox(height: defaultPadding),

                _buildProfileOption(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: "My Orders",
                  onTap: () {
                    Navigator.pushNamed(context, myOrdersScreenRoute);
                  },
                ),

                 _buildProfileOption(
                  context,
                  icon: Icons.system_update_alt_outlined, // or Icons.download
                  title: "App Download & Updates",
                  onTap: () {
                    Navigator.pushNamed(context, releaseHubScreenRoute);
                  },
                ),
                const Divider(height: defaultPadding * 2),
                

                // Help Center Options
                _buildProfileOption(
                  context,
                  icon: Icons.question_answer_outlined,
                  title: "FAQ",
                  onTap: () {
                    Navigator.pushNamed(context, faqScreenRoute);
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.safety_check_outlined,
                  title: "Safety Tips & Guides",
                  onTap: () {
                    Navigator.pushNamed(
                        context, safetyTipsAndGuidesScreenRoute);
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.support_agent_outlined,
                  title: "Support Center",
                  onTap: () {
                    Navigator.pushNamed(context, supportCenterRoute);
                  },
                ),
                const Divider(height: defaultPadding * 2),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      margin: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 18),
        onTap: onTap,
      ),
    );
  }
}