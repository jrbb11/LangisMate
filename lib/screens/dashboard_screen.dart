// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:langis_mate/widgets/header.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<Map<String, dynamic>?> _fetchDashboardData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final profileResult = await Supabase.instance.client
        .from('user_profiles')
        .select('first_name')
        .eq('user_id', userId)
        .maybeSingle();

    final profile = profileResult ?? {'first_name': 'User'};

    final motorcycles = await Supabase.instance.client
        .from('motorcycles')
        .select('id')
        .eq('user_id', userId);

    if (motorcycles.isEmpty) return {'first_name': profile['first_name']};

    final motorcycleId = motorcycles.first['id'];

    final oilChange = await Supabase.instance.client
        .from('oil_changes')
        .select('next_due, odometer')
        .eq('motorcycle_id', motorcycleId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return {
      'first_name': profile['first_name'],
      'next_due': oilChange?['next_due'],
      'odometer': oilChange?['odometer'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final accent = colors.primary;
    final cardColor = theme.cardColor;

    return Scaffold(
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 8),
    child: FutureBuilder<Map<String, dynamic>?>(
      future: _fetchDashboardData(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Header(
            title: 'Loading...',
            onMenuPressed: null,
            onProfilePressed: null,
            onSettingsPressed: null,
          );
        }
        // Error or no user
        if (snapshot.hasError || snapshot.data == null) {
          return const Header(
            title: 'Welcome!',
            onMenuPressed: null,
            onProfilePressed: null,
            onSettingsPressed: null,
          );
        }
        // Got data
        final firstName = snapshot.data!['first_name'] as String;
        return Header(
          title: 'Hello $firstName!',
          onMenuPressed: () => Scaffold.of(context).openDrawer(),
          onProfilePressed: () => Navigator.pushNamed(context, '/profile'),
          onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        );
      },
    ),
  ),
  body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: _fetchDashboardData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || snapshot.data == null || snapshot.data?['next_due'] == null) {
                  final firstName = snapshot.data?['first_name'] ?? 'User';
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          const Icon(Icons.motorcycle, size: 72, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text(
                            'No motorcycle found.\nPlease add a motorcycle first.',
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/add-motorcycle'),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Motorcycle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                final oilChangeDate = data['next_due'] != null
                    ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(data['next_due']))
                    : 'No upcoming date';
                final odometer = data['odometer'] != null ? '${data['odometer']} km' : '—';

                return Card(
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
                        Text(oilChangeDate, style: textTheme.bodyMedium),
                        Text('Odometer: $odometer', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.directions_bike,
                  label: 'Log Ride',
                  color: accent,
                  onTap: () {},
                ),
                _ActionButton(
                  icon: Icons.build,
                  label: 'Add Maintenance',
                  color: accent,
                  onTap: () => Navigator.pushNamed(context, '/app', arguments: 1),
                ),
                _ActionButton(
                  icon: Icons.store_mall_directory,
                  label: 'Find Shop',
                  color: accent,
                  onTap: () => Navigator.pushNamed(context, '/app', arguments: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
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
