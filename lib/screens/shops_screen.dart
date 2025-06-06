// lib/screens/shops_screen.dart

import 'package:flutter/material.dart';
import 'package:langis_mate/widgets/base_screen.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Find Shops',
      currentRoute: '/app',  // ← match the drawer’s routeName for Shops
      child: Center(
        child: Text(
          'Map & list of nearby shops',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
