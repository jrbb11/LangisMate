import 'package:flutter/material.dart';

const _orange = Color(0xFFFF8600);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: _orange,
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  cardColor: Colors.white,
  iconTheme: const IconThemeData(color: _orange),
  colorScheme: ColorScheme.light(
    primary: _orange,
    secondary: _orange.withOpacity(0.2),
  ),
  textTheme: const TextTheme(
    // 24sp bold → headlineSmall
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    // 18sp medium → titleMedium
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    // 14sp regular → bodyMedium
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: _orange,
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: const Color(0xFF2A2A2A),
  iconTheme: const IconThemeData(color: _orange),
  colorScheme: ColorScheme.dark(
    primary: _orange,
    secondary: _orange.withOpacity(0.2),
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.white60,
    ),
  ),
);
