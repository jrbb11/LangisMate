import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    // 1️⃣ Initialize Supabase (or comment this out to test)
    await Supabase.initialize(
      url: 'https://krfjzwkrpbeoithyperk.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZmp6d2tycGJlb2l0aHlwZXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NTgwMTMsImV4cCI6MjA2MjUzNDAxM30.crr3F74jdqPU7fx9duybm-gaPxoNsG4EklGcJoD5_08',
    );

    // 2️⃣ Decide your first screen
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;

    runApp(MyApp(seenOnboarding: seen));
  }, (error, stack) {
    // This will show the real error in your debug console
    debugPrint('🔥 Caught error in main(): $error');
    debugPrintStack(stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({
    super.key,
    required this.seenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 1) Keep the home launcher based on onboarding flag:
      home: seenOnboarding 
        ? const LoginScreen() 
        : const OnboardingScreen(),

      // 2) Then add your named routes in a `routes:` map:
      routes: {
        '/login':      (_) => const LoginScreen(),
        '/register':   (_) => const RegistrationScreen(),
        '/dashboard':  (_) => const DashboardScreen(),
      },
    );
  }
}
