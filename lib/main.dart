// lib/main.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/add_motorcycle_screen.dart';
import 'screens/shops_screen.dart';
import 'widgets/app_shell.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load onboarding & theme prefs
  final prefs          = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final themeIndex     = prefs.getInt('themeMode')     ?? 0; // 0=system,1=light,2=dark

  runZonedGuarded(
    () => runApp(MyApp(
      seenOnboarding:   seenOnboarding,
      initialThemeMode: ThemeMode.values[themeIndex],
    )),
    (error, stack) {
      debugPrint('🔥 Caught error in main(): $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class MyApp extends StatefulWidget {
  final bool      seenOnboarding;
  final ThemeMode initialThemeMode;

  const MyApp({
    super.key,
    required this.seenOnboarding,
    required this.initialThemeMode,
  });

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
    final user     = supabase.auth.currentUser;

    Widget home;
    if (!widget.seenOnboarding) {
      home = const OnboardingScreen();
    } else if (user == null) {
      home = const LoginScreen();
    } else {
      home = AppShell(
        currentMode:   _themeMode,
        onThemeChanged: _updateTheme,
      );
    }

    return MaterialApp(
      title:     'LangisMate',
      theme:      lightTheme,
      darkTheme:  darkTheme,
      themeMode:  _themeMode,
      home:       home,
      routes: {
        '/login':          (_) => const LoginScreen(),
        '/register':       (_) => const RegistrationScreen(),
       '/settings':       (_) => SettingsScreen(
                             currentMode:   _themeMode,
                             onThemeChanged: _updateTheme,
                           ),
        '/onboarding':     (_) => const OnboardingScreen(),
        '/dashboard':      (_) => AppShell(
                               currentMode:   _themeMode,
                               onThemeChanged: _updateTheme,
                             ),
        '/app':            (_) => AppShell(
                               currentMode:   _themeMode,
                               onThemeChanged: _updateTheme,
                             ),
        '/motorcycles': (_) => AppShell(
    initialIndex: 1,                     // Motorcycles is the 2nd tab
    currentMode: _themeMode,
    onThemeChanged: _updateTheme,
),
        '/shops':          (_) => const ShopsScreen(),
        '/profile': (_) => AppShell(
     initialIndex: 3,
     currentMode: _themeMode,
     onThemeChanged: _updateTheme,
  ),
        '/add-motorcycle': (_) => const AddMotorcycleScreen(),
      },
    );
  }
}
