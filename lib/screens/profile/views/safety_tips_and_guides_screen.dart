// lib/screens/profile/views/safety_tips_and_guides_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/screens/profile/views/components/tips.dart';


class SafetyTipsAndGuidesScreen extends StatelessWidget {
  const SafetyTipsAndGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Tips & Guides"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: const [
          Tip(
            title: "Responsible Use Guidelines",
            tips: [
              "Always start with a low dose, especially if you are new to cannabis products. Wait to see how it affects you before consuming more.",
              "Understand the different methods of consumption (e.g., edibles, oils, flower) and how they affect onset time and duration.",
              "Do not drive or operate heavy machinery under the influence of cannabis.",
              "Keep all cannabis products out of reach of children and pets. Store them in child-resistant containers.",
            ],
          ),
          Tip(
            title: "Understanding Products & Effects",
            tips: [
              "Familiarize yourself with product labels, including THC/CBD content and terpene profiles. Use JahBuk to learn more about strains.",
              "Be aware of potential side effects, such as dry mouth, red eyes, dizziness, or anxiety. Stay hydrated.",
              "Understand the difference between Indica (often relaxing), Sativa (often uplifting), and Hybrid strains.",
              "If you feel uncomfortable or too high, try to relax, stay hydrated, and focus on slow breathing. A dose of CBD can sometimes help to counteract THC effects.",
            ],
          ),
          Tip(
            title: "Legal & Social Considerations",
            tips: [
              "Be aware of and comply with all local laws and regulations regarding cannabis consumption, possession, and purchase in your area (e.g., Seeta, Central Region, Uganda).",
              "Consume in private settings where permissible and respect public spaces.",
              "Do not share cannabis with minors or individuals who are not legally permitted to consume it.",
            ],
          ),
          Tip(
            title: "Emergency & Support",
            tips: [
              "If you or someone you know has an adverse reaction, seek medical attention immediately.",
              "If you suspect a minor has consumed cannabis, contact emergency services or a poison control center.",
              "For any product-related concerns or general inquiries, contact our support team through the app's 'Support Contacts' section.",
            ],
          ),
        ],
      ),
    );
  }
}
