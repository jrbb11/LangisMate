// lib/screens/motorcycles_screen.dart

import 'package:flutter/material.dart';
import 'package:langis_mate/widgets/base_screen.dart';

class MotorcyclesScreen extends StatelessWidget {
  const MotorcyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title:        'My Motorcycles',
      currentRoute: '/motorcycles',
      child: Center(
        child: Text(
          'List your motorcycles here',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
