// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:langis_mate/widgets/base_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<Map<String, dynamic>?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>?> _fetchDashboardData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final profileResult = await Supabase.instance.client
        .from('user_profiles')
        .select('first_name')
        .eq('user_id', userId)
        .maybeSingle();
    final profile = profileResult ?? {'first_name': 'User'};

    final bikes = await Supabase.instance.client
        .from('motorcycles')
        .select('id')
        .eq('user_id', userId);

    if (bikes.isEmpty) {
      return {'first_name': profile['first_name']};
    }

    final bikeId = bikes.first['id'];
    final oilChange = await Supabase.instance.client
        .from('oil_changes')
        .select('next_due, odometer')
        .eq('motorcycle_id', bikeId)
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
    final theme     = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent    = theme.colorScheme.primary;
    final cardColor = theme.cardColor;

    return BaseScreen(
      title: 'LangisMate',
      currentRoute: '/dashboard',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Flexible with loose fit lets the FutureBuilder/card 
            // only be as tall as its content
            Flexible(
              fit: FlexFit.loose,
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _dashboardFuture,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data;
                  if (snapshot.hasError || data == null || data['next_due'] == null) {
                    final firstName = data?['first_name'] as String? ?? 'User';
                    return _buildEmptyState(textTheme, cardColor, firstName);
                  }
                  final nextDueRaw = data['next_due'] as String;
                  final nextDue = DateFormat('MMMM dd, yyyy')
                      .format(DateTime.parse(nextDueRaw));
                  final odometer = '${data['odometer']} km';
                  return _buildInfoCard(textTheme, cardColor, accent, nextDue, odometer);
                },
              ),
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
                  icon: Icons.motorcycle,
                  label: 'My Motorcycle',
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

  Widget _buildEmptyState(TextTheme textTheme, Color cardColor, String firstName) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content vertically
          children: [
            const Icon(Icons.motorcycle, size: 72, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Hello $firstName!\nNo motorcycle found.\nPlease add one.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-motorcycle'),
              icon: const Icon(Icons.add),
              label: const Text('Add Motorcycle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    TextTheme textTheme,
    Color cardColor,
    Color accent,
    String nextDue,
    String odometer,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: accent),
                const SizedBox(width: 6),
                Text(
                  'LangisMate',
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Next Oil Change',
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(nextDue, style: textTheme.bodyMedium),
            Text('Odometer: $odometer', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
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
