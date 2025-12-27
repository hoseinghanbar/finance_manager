// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // فقط تم روشن
  static ThemeData lightTheme = ThemeData(
    // رنگ اصلی
    primaryColor: Colors.blue.shade800,
    primarySwatch: Colors.blue,
    
    // رنگ‌های رابط
    scaffoldBackgroundColor: Colors.grey.shade50,
    cardColor: Colors.white,
    canvasColor: Colors.white,
    
    // رنگ متن
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
    
    // رنگ‌های آیکون
    iconTheme: const IconThemeData(color: Colors.black87),
    
    // رنگ دکمه
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // رنگ ورودی‌ها
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    
    // رنگ AppBar
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    
    // رنگ‌های کارت
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // رنگ‌های دایورجنت
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade700,
      secondary: Colors.orange.shade700,
      background: Colors.grey.shade50,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
    ),
    
    // فونت فارسی
    fontFamily: 'Vazir', // اگر فونت فارسی داری
  );

  // حذف darkTheme
  // static ThemeData darkTheme = ThemeData.dark();
  
  // حذف themeMode
  // themeMode: ThemeMode.system,
}