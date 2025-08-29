// lib/screens/onbording/views/onbording_screnn.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/hubs_entry_point.dart'; // ** THE FIX IS HERE **

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  // REMOVED: The _showOnboardingPopup method is no longer needed.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              "assets/images/onboard_1.png",
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    "Welcome to Green Gold Corps",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding),
                  const Text(
                    "Your one-stop comprehensive app for cannabis products and knowledge.",
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    // ** THE FIX IS HERE: Navigate directly to the HubsEntryPoint **
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HubsEntryPoint()),
                      );
                    },
                    child: const Text("Get Started"),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}