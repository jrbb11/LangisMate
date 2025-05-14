// lib/widgets/app_shell.dart

import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/motorcycles_screen.dart';  // ← updated
import '../screens/shops_screen.dart';
import '../screens/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    Key? key,
    this.initialIndex = 0,
    required this.currentMode,
    required this.onThemeChanged,
  }) : super(key: key);

  final int initialIndex;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int && arg != _currentIndex) {
      setState(() => _currentIndex = arg);
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const MotorcyclesScreen();   // ← swapped in
      case 2:
        return const ShopsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),    // ← changed
            label: 'Motorcycles',            // ← changed
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
