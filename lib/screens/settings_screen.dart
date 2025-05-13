import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    required this.currentMode,
    required this.onThemeChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
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
