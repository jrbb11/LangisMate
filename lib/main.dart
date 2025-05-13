// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://krfjzwkrpbeoithyperk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZmp6d2tycGJlb2l0aHlwZXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NTgwMTMsImV4cCI6MjA2MjUzNDAxM30.crr3F74jdqPU7fx9duybm-gaPxoNsG4EklGcJoD5_08',
  );

  // Load onboarding & theme prefs
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final themeIndex = prefs.getInt('themeMode') ?? 0; // 0=system,1=light,2=dark

  runZonedGuarded(
    () => runApp(MyApp(
      seenOnboarding: seenOnboarding,
      initialThemeMode: ThemeMode.values[themeIndex],
    )),
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
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Decide initial screen
    Widget home;
    if (!widget.seenOnboarding) {
      home = const OnboardingScreen();
    } else if (user == null) {
      home = const LoginScreen();
    } else {
      home = AppShell(
        currentMode: _themeMode,
        onThemeChanged: _updateTheme,
      );
    }

    return MaterialApp(
      title: 'LangisMate',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: home,
      routes: {
        '/login':      (_) => const LoginScreen(),
        '/register':   (_) => const RegistrationScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/dashboard':  (_) => AppShell(              // ← added dashboard route
                          currentMode: _themeMode,
                          onThemeChanged: _updateTheme,
                        ),
        '/app':        (_) => AppShell(
                          currentMode: _themeMode,
                          onThemeChanged: _updateTheme,
                        ),
      },
    );
  }
}
