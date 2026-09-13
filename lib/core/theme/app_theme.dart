import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE50914);
  static const Color secondaryColor = Color(0xFF00D4AA);
  static const Color backgroundColor = Color(0xFF0A0A0F);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color textMutedColor = Color(0xFF6B6B6B);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, Color(0xFF0F0F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceColor, cardColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const TextStyle headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor, letterSpacing: -0.5);
  static const TextStyle headlineMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryColor, letterSpacing: -0.3);
  static const TextStyle headlineSmall = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryColor);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimaryColor, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondaryColor, height: 1.4);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textMutedColor, height: 1.3);
  static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor, letterSpacing: 0.5);

  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
  );

  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: bodyMedium.copyWith(color: textMutedColor),
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: surfaceColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(primary: primaryColor, secondary: secondaryColor, surface: surfaceColor, error: errorColor),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, titleTextStyle: TextStyle(color: textPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
    cardTheme: CardTheme(color: surfaceColor, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: textPrimaryColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: buttonText)),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: surfaceColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: surfaceColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
  );
}