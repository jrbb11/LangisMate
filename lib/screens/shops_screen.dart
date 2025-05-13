// lib/screens/shops_screen.dart

import 'package:flutter/material.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shops')),
      body: const Center(child: Text('Nearby repair shops will show here')),
    );
  }
}
