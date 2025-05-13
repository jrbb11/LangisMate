import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://krfjzwkrpbeoithyperk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZmp6d2tycGJlb2l0aHlwZXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NTgwMTMsImV4cCI6MjA2MjUzNDAxM30.crr3F74jdqPU7fx9duybm-gaPxoNsG4EklGcJoD5_08',
  );

  // Load onboarding & theme prefs
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final themeIndex = prefs.getInt('themeMode') ?? 0; // 0=system,1=light,2=dark

  runZonedGuarded(
    () {
      runApp(MyApp(
        seenOnboarding: seenOnboarding,
        initialThemeMode: ThemeMode.values[themeIndex],
      ));
    },
    (error, stack) {
      debugPrint('🔥 Caught error in main(): $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class MyApp extends StatefulWidget {
  final bool seenOnboarding;
  final ThemeMode initialThemeMode;

  const MyApp({
    Key? key,
    required this.seenOnboarding,
    required this.initialThemeMode,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _updateTheme(ThemeMode newMode) async {
    setState(() => _themeMode = newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', ThemeMode.values.indexOf(newMode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangisMate',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,

      // Onboarding flow
      home: widget.seenOnboarding
          ? const LoginScreen()
          : const OnboardingScreen(),

      // Named routes
      routes: {
        '/login':     (_) => const LoginScreen(),
        '/register':  (_) => const RegistrationScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/settings':  (_) => SettingsScreen(
                           currentMode: _themeMode,
                           onThemeChanged: _updateTheme,
                         ),
      },
    );
  }
}
