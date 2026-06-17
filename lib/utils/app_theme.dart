import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Couleurs ─────────────────────────────────────────────────────────────
  static const Color _primaryLight = Color(0xFF007AFF);
  static const Color _primaryDark  = Color(0xFF0A84FF);
  static const Color _surfaceLight = Color(0xFFF2F2F7);
  static const Color _surfaceDark  = Color(0xFF1C1C1E);

  // ─── Thème clair ─────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryLight,
          brightness: Brightness.light,
          surface: _surfaceLight,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: _surfaceLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: _primaryLight,
          unselectedItemColor: Color(0xFF8E8E93),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E5EA),
          space: 1,
          thickness: 0.5,
        ),
      );

  // ─── Thème sombre ─────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryDark,
          brightness: Brightness.dark,
          surface: _surfaceDark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: _surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _surfaceDark,
          selectedItemColor: _primaryDark,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF38383A),
          space: 1,
          thickness: 0.5,
        ),
      );
}