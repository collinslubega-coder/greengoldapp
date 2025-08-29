// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';

class AppTheme {
  // === COLOR CHANGED TO WHITE ===
  static const Color highContrastColor = Colors.white; 

  // The shadow definition remains to provide contrast against the background
  static const List<Shadow> textAndIconShadows = [
    Shadow(
      blurRadius: 3.0,
      color: Color.fromRGBO(0, 0, 0, 0.8), // A semi-transparent black
      offset: Offset(1, 2),
    ),
  ];

  static const Color lightScaffoldBackgroundColor = Color(0xFFF7F7F7);
  static const Color lightTextColor = Color(0xFF16161E);
  static const Color lightSurfaceColor = Colors.white;

  static const Color darkScaffoldBackgroundColor = Color(0xFF0D0D0D);
  static const Color darkTextColor = Colors.white; 
  static const Color darkSurfaceColor = Color(0xFF1D1D1D);

  // Light theme remains unchanged
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: grandisExtendedFont,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: lightSurfaceColor,
        onSurface: lightTextColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextColor),
        titleTextStyle: TextStyle(
            color: lightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: grandisExtendedFont),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: grandisExtendedFont),
        ),
      ),
    );
  }

  // Dark theme now uses white text/icons with shadows
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: grandisExtendedFont,
      
      cardTheme: CardThemeData(
        color: const Color.fromRGBO(0, 0, 0, 0.6), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        displayMedium: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        displaySmall: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        headlineLarge: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        headlineMedium: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        headlineSmall: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        titleLarge: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        titleMedium: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        titleSmall: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        bodyLarge: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        bodyMedium: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        bodySmall: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        labelLarge: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        labelMedium: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
        labelSmall: TextStyle(color: highContrastColor, shadows: textAndIconShadows),
      ),

      iconTheme: const IconThemeData(
        color: highContrastColor,
        shadows: textAndIconShadows,
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkSurfaceColor,
        onSurface: highContrastColor, 
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: highContrastColor, shadows: textAndIconShadows),
        titleTextStyle: TextStyle(
            color: highContrastColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: grandisExtendedFont,
            shadows: textAndIconShadows),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: highContrastColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: grandisExtendedFont,
              shadows: textAndIconShadows),
        ),
      ),
    );
  }
}