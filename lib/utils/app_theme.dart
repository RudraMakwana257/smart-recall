import 'package:flutter/material.dart';

class AppTheme {
  // Border Radius
  static const double borderRadiusLarge = 18.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusSmall = 8.0;

  // Font Families
  static const String displayFont = 'Road Rage';
  static const String bodyFont = 'Roboto';

  // Font Sizes
  static const double displayLarge = 48.0;
  static const double displayMedium = 32.0;
  static const double headlineLarge = 24.0;
  static const double headlineMedium = 20.0;
  static const double bodyLarge = 18.0;
  static const double bodyMedium = 16.0;
  static const double bodySmall = 14.0;

  // Light Mode Colors
  static const Color primaryBlue = Color(0xFF2496B8);
  static const Color primaryPurple = Color(0xFFA53F6F);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color darkNavy = Color(0xFF1A1F36);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF161210);
  static const Color darkSecondaryBackground = Color(0xFF201B18);
  static const Color darkCardBackground = Color(0xFF2A2421);
  static const Color darkPrimaryBlue = Color(0xFF2496B8);
  static const Color darkPrimaryPurple = Color(0xFFA53F6F);
  static const Color darkTextPrimary = Color(0xFFF4F0EC);
  static const Color darkTextSecondary = Color(0xFFA89F96);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkModeGradient = LinearGradient(
    colors: [Color(0xFF2496B8), Color(0xFF8A345C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBlueGradient = LinearGradient(
    colors: [Color(0xFF2496B8), Color(0xFF167FA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(0.785), // 45 degrees in radians
  );

  static const LinearGradient darkPurpleGradient = LinearGradient(
    colors: [Color(0xFFA53F6F), Color(0xFF8A345C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(0.785),
  );

  // Shadows
  static List<BoxShadow> lightModeShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkModeShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: displayLarge,
        fontFamily: displayFont,
        color: darkNavy,
      ),
      displayMedium: TextStyle(
        fontSize: displayMedium,
        fontFamily: displayFont,
        color: darkNavy,
      ),
      headlineLarge: TextStyle(
        fontSize: headlineLarge,
        fontWeight: FontWeight.bold,
        color: darkNavy,
      ),
      headlineMedium: TextStyle(
        fontSize: headlineMedium,
        fontWeight: FontWeight.bold,
        color: darkNavy,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyLarge,
        color: darkNavy,
      ),
      bodyMedium: TextStyle(
        fontSize: bodyMedium,
        color: darkNavy,
      ),
      bodySmall: TextStyle(
        fontSize: bodySmall,
        color: darkNavy,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryBlue,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: displayLarge,
        fontFamily: displayFont,
        color: darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: displayMedium,
        fontFamily: displayFont,
        color: darkTextPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: headlineLarge,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: headlineMedium,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyLarge,
        color: darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: bodyMedium,
        color: darkTextSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: bodySmall,
        color: darkTextSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSecondaryBackground,
      foregroundColor: darkTextPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSecondaryBackground,
      selectedItemColor: darkPrimaryBlue,
      unselectedItemColor: darkTextSecondary,
    ),
    iconTheme: const IconThemeData(
      color: darkTextPrimary,
    ),
    dividerColor: darkTextSecondary.withOpacity(0.2),
  );
}

