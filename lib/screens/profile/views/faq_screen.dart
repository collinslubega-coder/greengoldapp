// lib/screens/profile/views/faq_screen.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';


class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: const [
          FaqItem(
            question: "What kind of cannabis products do you sell?",
            answer: "We offer a curated selection of premium cannabis products including Bud (Flower), Pre-rolls, Edibles (like cookies, gummies, and chocolates), and various Cannabis Oils (such as shea butter and olive oil infusions).",
          ),
          FaqItem(
            question: "What is JahBuk?",
            answer: "JahBuk is our comprehensive encyclopedia of cannabis strains. It's a learning center where you can explore detailed information about different strains, their effects, terpenes, and potential wellness applications. We do not sell all strains listed in JahBuk.",
          ),
          FaqItem(
            question: "Do you offer delivery services?",
            answer: "Yes, we offer discreet and reliable delivery services within our operational areas. Delivery fees and times vary by location.",
          ),
          FaqItem(
            question: "What payment methods do you accept?",
            answer: "We currently accept Mobile Money payments only. You'll receive payment instructions after placing order.",
          ),
          FaqItem(
            question: "How long does delivery usually take?",
            answer: "We strive for prompt delivery. Once your order is confirmed, our team will provide an estimated delivery time. Most local deliveries are completed within a few hours to the same day.",
          ),
          FaqItem(
            question: "How can I contact customer support?",
            answer: "You can find our support contacts in the 'Support Contacts' section of your profile. We are available via phone and email to assist you.",
          ),
        ],
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(answer),
          )
        ],
      ),
    );
  }
}
