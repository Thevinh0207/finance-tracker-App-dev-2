import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF4A90D9);
  static const Color brandBlueDark = Color(0xFF1A56C4);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Color(0xFFF4F6FA),
      cardColor: Colors.white,
      dividerColor: Color(0xFFEEEEEE),
      primaryColor: brandBlue,
      colorScheme: ColorScheme.light(
        primary: brandBlue,
        secondary: brandBlueDark,
        surface: Colors.white,
        onSurface: Color(0xFF1A1A2E),
        background: Color(0xFFF4F6FA),
        onBackground: Color(0xFF1A1A2E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFF4F6FA),
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Color(0xFF13131F),
      cardColor: Color(0xFF1E1E33),
      dividerColor: Color(0xFF2D2D45),
      primaryColor: brandBlue,
      colorScheme: ColorScheme.dark(
        primary: brandBlue,
        secondary: brandBlueDark,
        surface: Color(0xFF1E1E33),
        onSurface: Colors.white,
        background: Color(0xFF13131F),
        onBackground: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF13131F),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
