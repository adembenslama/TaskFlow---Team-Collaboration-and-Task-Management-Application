import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasLeadingIcon;
  final VoidCallback? onLeadingIconTap;
  final List<Widget>? actions;

  CustomAppBar({
    required this.title,
    this.hasLeadingIcon = false,
    this.onLeadingIconTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      leading: hasLeadingIcon
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onLeadingIconTap ?? () {
                Scaffold.of(context).openDrawer();
              },
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
