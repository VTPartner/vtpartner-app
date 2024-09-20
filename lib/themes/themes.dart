import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vt_partner/utils/app_styles.dart';

class ThemeClass {
  static const Color facebookBlue = Color(0xFF0042D9);
  static const Color backgroundColor2 = Color(0xFF17203A);
  static const Color backgroundColorLight = Color(0xFFF2F6FF);
  // static const Color backgroundColorLightPink = Color(0xFFFEF1F2);
  static const Color backgroundColorLightPink = Color(0xFFF0F5FF);
  static const Color backgroundColorDark = Color(0xFF25254B);
  static const Color shadowColorLight = Color(0xFF4A5367);
  static const Color shadowColorDark = Colors.black;

  static ThemeData get themeData {
    // Set the status bar color globally
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Colors.grey[100], // Set the notification tray color to facebookBlue
      statusBarIconBrightness:
          Brightness.dark, // Set the icons to be light-colored
    ));
    return ThemeData(
      // Define the overall color scheme

      colorScheme: ColorScheme(
        primary: facebookBlue, // Primary color
        secondary: facebookBlue, // Secondary color
        surface: Colors.white,
        background: Colors.grey[200]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: ThemeClass.backgroundColorLightPink,

      // App bar theme
      appBarTheme: const AppBarTheme(
        color: facebookBlue,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.black),
        // Uncomment and adjust as needed
        // textTheme: TextTheme(
        //   headlineLarge: TextStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //   ),
        // ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        // backgroundColor: facebookBlue,
        selectedItemColor: facebookBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),

      // Bottom app bar theme
      bottomAppBarTheme: const BottomAppBarTheme(
        color: facebookBlue,
        elevation: 8,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: facebookBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: nunitoSansStyle.copyWith(color: Colors.grey),
        labelStyle: nunitoSansStyle.copyWith(color: facebookBlue),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: facebookBlue,
        size: 24,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: const TextStyle(
            fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
        displayMedium: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        headlineLarge: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        headlineSmall: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        titleMedium: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        titleSmall: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: const TextStyle(fontSize: 16, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
        bodySmall: TextStyle(fontSize: 12, color: Colors.grey[600]),
        labelLarge: TextStyle(fontSize: 16, color: facebookBlue),
        labelMedium: TextStyle(fontSize: 14, color: facebookBlue),
        labelSmall: TextStyle(fontSize: 12, color: facebookBlue),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),

      // Define primary color
      primaryColor: facebookBlue,

      // Text selection theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: facebookBlue,
        selectionColor: facebookBlue.withOpacity(0.3),
        selectionHandleColor: facebookBlue,
      ),
    );
  }
}
