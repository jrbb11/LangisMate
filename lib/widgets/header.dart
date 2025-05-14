import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Gradient backgroundGradient;
  final Color iconColor;
  final Color titleColor;
  final double height;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.backgroundGradient = const LinearGradient(
      colors: [Color(0xFFFFD8A6), Color(0xFFED6A43)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
    this.height = kToolbarHeight + 24, // a bit taller
    this.onMenuPressed,
    this.onBackPressed,
    this.onProfilePressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 4,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  showBackButton ? Icons.arrow_back : Icons.menu,
                  color: iconColor,
                  size: 28,
                ),
                onPressed: showBackButton
                    ? (onBackPressed ?? () => Navigator.of(context).pop())
                    : onMenuPressed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onProfilePressed != null)
                IconButton(
                  icon: Icon(Icons.person, color: iconColor, size: 28),
                  onPressed: onProfilePressed,
                ),
              if (onSettingsPressed != null)
                IconButton(
                  icon: Icon(Icons.settings, color: iconColor, size: 28),
                  onPressed: onSettingsPressed,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
