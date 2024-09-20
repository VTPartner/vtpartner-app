import 'package:flutter/material.dart';

class DarkAndLightThemeClass {
  // Facebook colors
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF0F2F5);
  static const Color lightTextColor = Color(0xFF606770);
  static const Color lightSecondaryColor = Color(0xFFB0B3B8);

  static const Color darkBackgroundColor = Color(0xFF18191A);
  static const Color darkSurfaceColor = Color(0xFF242526);
  static const Color darkTextColor = Color(0xFFB0B3B8);
  static const Color darkSecondaryColor = Color(0xFF606770);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: facebookBlue,
      secondary: lightSecondaryColor,
      background: lightBackgroundColor,
      surface: lightSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: lightTextColor,
      onBackground: Colors.black,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      color: facebookBlue,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: lightSurfaceColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: facebookBlue,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurfaceColor,
      selectedItemColor: facebookBlue,
      unselectedItemColor: lightTextColor,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: lightTextColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: lightSecondaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    cardTheme: CardTheme(
      color: lightSurfaceColor,
      shadowColor: Colors.black.withOpacity(0.2), // More pronounced shadow
      elevation: 8.0, // Enhanced shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26.0),
          topRight: Radius.circular(26.0),
        ),
      ),
      elevation: 10.0, // Enhanced bottom sheet elevation
      modalElevation: 16.0, // Enhanced modal elevation
    ),
    iconTheme: const IconThemeData(
      color: facebookBlue, // All icons will use facebookBlue color
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: facebookBlue,
      secondary: darkSecondaryColor,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: darkTextColor,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      color: facebookBlue,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: darkSurfaceColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: facebookBlue,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: facebookBlue,
      unselectedItemColor: darkTextColor,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: darkTextColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: darkSecondaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    cardTheme: CardTheme(
      color: darkSurfaceColor,
      shadowColor: Colors.black.withOpacity(0.2), // More pronounced shadow
      elevation: 8.0, // Enhanced shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26.0),
          topRight: Radius.circular(26.0),
        ),
      ),
      elevation: 10.0, // Enhanced bottom sheet elevation
      modalElevation: 16.0, // Enhanced modal elevation
    ),
    iconTheme: const IconThemeData(
      color: facebookBlue, // All icons will use facebookBlue color
    ),
  );
}
