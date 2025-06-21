import 'package:flutter/material.dart';

class AppTheme {
  // Цветовая палитра
  static const Color primaryColor = Color(0xFF00B2FF); 
  static const Color backgroundColor = Color(0xFF0D1117); 
  static const Color cardColor = Color(0xFF161B22); 
  static const Color fontColor = Colors.white; 
  static const Color secondaryFontColor = Color(0xFF8B949E); 

  // Главная тема приложения
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Inter',
      splashColor: primaryColor.withOpacity(0.2),
      highlightColor: primaryColor.withOpacity(0.1),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: fontColor, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: fontColor, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: fontColor, fontWeight: FontWeight.w500, fontSize: 18),
        bodyMedium: TextStyle(color: fontColor, fontSize: 16),
        bodySmall: TextStyle(color: secondaryFontColor, fontSize: 14),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.bold)
        )
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: primaryColor, width: 2)),
        labelStyle: TextStyle(color: secondaryFontColor),
      ),
      
      tabBarTheme: const TabBarThemeData(
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primaryColor, width: 3)),
        labelColor: primaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 16),
        unselectedLabelColor: secondaryFontColor,
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontFamily: 'Inter', fontSize: 16),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: cardColor,
        textColor: fontColor,
        iconColor: primaryColor,
        subtitleTextStyle: const TextStyle(color: secondaryFontColor)
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      )
    );
  }
}