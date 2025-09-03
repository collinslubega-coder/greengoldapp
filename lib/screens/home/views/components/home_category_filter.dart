// lib/screens/home/views/components/home_category_filter.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:green_gold/constants.dart';


class HomeCategoryFilter extends StatelessWidget {
  const HomeCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    // Categories for your cannabis shop products
    final List<Map<String, String>> categories = [
      {"name": "Ointments & Accessories", "icon": "assets/icons/cannabis_oil.svg"},
      {"name": "Edibles", "icon": "assets/icons/cannabis_edible.svg"},
      {"name": "Flowers", "icon": "assets/icons/cannabis_bud.svg"}, // Renamed from "Bud"
      // REMOVED: "Pre-rolls" category
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (index) {
            final category = categories[index];
            final bool isSelected = selectedCategory == category["name"];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? defaultPadding : defaultPadding / 2,
                right: index == categories.length - 1 ? defaultPadding : 0,
              ),
              child: OutlinedButton(
                onPressed: () => onCategorySelected(category["name"]!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  shape: const StadiumBorder(),
                  // ** THE FIX IS HERE **
                  // The border color now uses our new gold accent.
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : goldColor,
                  )
                ),
                child: Row(
                  children: [
                    if (category["icon"] != null)
                      SvgPicture.asset(
                        category["icon"]!,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge!.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                    if (category["icon"] != null) const SizedBox(width: defaultPadding / 2),
                    Text(category["name"]!),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}