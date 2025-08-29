// lib/screens/hubs/entertainment_hub/components/vibe_score_display.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';

class VibeScoreDisplay extends StatelessWidget {
  final double voteAverage;
  final int voteCount;

  const VibeScoreDisplay({
    super.key,
    required this.voteAverage,
    required this.voteCount,
  });

  String get _descriptiveLabel {
    if (voteCount > 5000) {
      return "Community Certified";
    } else if (voteCount > 500) {
      return "Popular Vibe";
    } else if (voteCount > 0) {
      return "Niche Vibe";
    } else {
      return "Not Yet Rated";
    }
  }

  @override
  Widget build(BuildContext context) {
    // The ratingOutOfFive is only used for the leaf calculation
    final double ratingOutOfFive = voteAverage / 2;
    // --- NEW: Calculate the percentage score ---
    final int percentageScore = (voteAverage * 10).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Generate the 5 leaf icons (logic remains the same)
            ...List.generate(5, (index) {
              if (index < ratingOutOfFive.floor()) {
                return const Icon(Icons.spa, color: primaryColor);
              } else if (index < ratingOutOfFive) {
                return const Icon(Icons.spa_outlined, color: primaryColor);
              } else {
                return Icon(Icons.spa_outlined, color: Colors.grey.shade600);
              }
            }),
            const SizedBox(width: defaultPadding),

            // --- FIX IS HERE: Updated text display ---
            // Display the score out of 10 and the percentage
            Text(
              "${voteAverage.toStringAsFixed(1)}/10  ($percentageScore%)",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding / 4),
        // The descriptive label remains the same
        Text(
          _descriptiveLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}