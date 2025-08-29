// lib/screens/login/views/user_login_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/route/route_constants.dart'; // Import route constants
// Removed UserDataService and form_field_validator as they are no longer used here.

class UserLoginScreen extends StatelessWidget { // Changed to StatelessWidget
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Denied"), // Changed title for clarity
        automaticallyImplyLeading: false, // Hide default back button
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined), // Admin icon
            tooltip: "Admin Access",
            onPressed: () {
              // Navigate to the Admin Authentication Screen
              Navigator.pushNamed(context, adminAuthScreenRoute);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Center(
            child: SingleChildScrollView(
              child: Column( // Changed from Form to Column
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo/logo.png",
                    height: 120,
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  Text(
                    "Unauthorized Access",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding),
                  const Text(
                    "This is not the main login for customers. Please use the authorization code on the main onboarding screen to proceed.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the initial onboarding screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        onbordingScreenRoute,
                        (route) => false,
                      );
                    },
                    child: const Text("Go to Get Started"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}