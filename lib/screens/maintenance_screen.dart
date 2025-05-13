// lib/screens/maintenance_screen.dart

import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: const Center(child: Text('Maintenance entries will show here')),
    );
  }
}
