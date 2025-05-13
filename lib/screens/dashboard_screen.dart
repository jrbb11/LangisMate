// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors    = theme.colorScheme;
    final accent    = colors.primary;
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Good morning, John!', style: textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Switch to Settings tab in AppShell:
              DefaultTabController.of(context)?.animateTo(3);
              // Or if you don't use TabController, push via named route:
              Navigator.pushNamed(context, '/app', arguments: 3);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Next Oil Change Card ───────────────────────────
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: accent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'LangisMate',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Next Oil Change',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('April 25, 2025', style: textTheme.bodyMedium),
                    Text('6,500 ml remaining', style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Quick Action Buttons ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.directions_bike,
                  label: 'Log Ride',
                  color: accent,
                  onTap: () {
                    // e.g. open log ride flow
                  },
                ),
                _ActionButton(
                  icon: Icons.build,
                  label: 'Add Maintenance',
                  color: accent,
                  onTap: () {
                    // switch to Maintenance tab (index 1)
                    Navigator.pushNamed(context, '/app', arguments: 1);
                  },
                ),
                _ActionButton(
                  icon: Icons.store_mall_directory,
                  label: 'Find Shop',
                  color: accent,
                  onTap: () {
                    // switch to Shops tab (index 2)
                    Navigator.pushNamed(context, '/app', arguments: 2);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Repair Shops Preview ───────────────────────────
            Text('Repair Shops', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _ShopTile(name: 'Speed Auto Service', distance: '1.2 km'),
                  _ShopTile(name: 'MotoFix Center', distance: '2.5 km'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData    icon;
  final String      label;
  final Color       color;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: body),
      ],
    );
  }
}

class _ShopTile extends StatelessWidget {
  final String name;
  final String distance;

  const _ShopTile({
    super.key,
    required this.name,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.store, color: Theme.of(context).iconTheme.color),
        title: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(distance, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // maybe open shop details
        },
      ),
    );
  }
}
