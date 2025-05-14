// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final colors  = theme.colorScheme;
    final isDark  = theme.brightness == Brightness.dark;

    // Pick a gradient that works in dark or light mode
    final headerGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFD8A6), Color(0xFFED6A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor     = colors.onSurface;
    final activeColor   = colors.primary;
    // use withAlpha instead of withOpacity
    final inactiveColor = colors.onSurface.withAlpha((0.8 * 255).toInt());

    final user     = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    final avatarUrl= metadata['avatar_url'] as String?;
    final fullName = (metadata['full_name'] as String?) ?? 'Guest User';

    return Drawer(
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              height: 200,
              decoration: BoxDecoration(gradient: headerGradient),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/avatar_placeholder.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildTile(
                      context,
                      icon: Icons.home,
                      label: 'Home',
                      routeName: '/dashboard',
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                    _buildTile(
                      context,
                      icon: Icons.motorcycle,
                      label: 'Motorcycles',
                      routeName: '/motorcycles',
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                    _buildTile(
                      context,
                      icon: Icons.store,
                      label: 'Shops',
                      routeName: '/shops',
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildTile(
                      context,
                      icon: Icons.person,
                      label: 'Profile',
                      routeName: '/profile',
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                    _buildTile(
                      context,
                      icon: Icons.settings,
                      label: 'Settings',
                      routeName: '/settings',
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                    _buildTile(
                      context,
                      icon: Icons.logout,
                      label: 'Logout',
                      routeName: '/login',
                      isLogout: true,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
    Object? arguments,
    bool isLogout = false,
    required Color activeColor,
    required Color inactiveColor,
    required Color textColor,
  }) {
    final bool isActive = currentRoute == routeName;

    return ListTile(
      leading: Icon(icon, color: isActive ? activeColor : inactiveColor),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? activeColor : textColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      // use withAlpha instead of withOpacity
      selectedTileColor: activeColor.withAlpha((0.1 * 255).toInt()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          Supabase.instance.client.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
        Navigator.pushReplacementNamed(
          context,
          routeName,
          arguments: arguments,
        );
      },
    );
  }
}
