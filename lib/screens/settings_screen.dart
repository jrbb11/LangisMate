// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:langis_mate/widgets/base_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Settings',
      currentRoute: '/settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: ThemeMode.values.map((mode) {
          final label = {
            ThemeMode.system: 'Use System Theme',
            ThemeMode.light:  'Light Theme',
            ThemeMode.dark:   'Dark Theme',
          }[mode]!;

          return RadioListTile<ThemeMode>(
            title: Text(label),
            value: mode,
            groupValue: currentMode,
            onChanged: (selected) {
              if (selected != null) onThemeChanged(selected);
            },
          );
        }).toList(),
      ),
    );
  }
}
