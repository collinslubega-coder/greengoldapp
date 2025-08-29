// lib/components/shared_staff_app_bar.dart

import 'package:flutter/material.dart';
import 'package:green_gold/entry_point.dart';

class SharedStaffAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const SharedStaffAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.storefront_outlined),
          tooltip: "View Customer Shop",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EntryPoint()),
            );
          },
        ),
      ],
    );
  }
}
