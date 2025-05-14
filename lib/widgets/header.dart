// lib/widgets/header.dart

import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const Header({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.onMenuPressed,
    this.onProfilePressed,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD8A6), Color(0xFFED6A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF823A0E),
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF823A0E)),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF823A0E)),
              onPressed: onMenuPressed,
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Color(0xFF823A0E)),
          onPressed: onProfilePressed,
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF823A0E)),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
