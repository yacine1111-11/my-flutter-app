import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
