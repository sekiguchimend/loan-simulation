import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // カラー定数
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textColor = Color(0xFF2C2C2C);
  static const Color primaryColor = Color(0xFF660F15);

  static ThemeData get lightTheme {
    return ThemeData(
      // カラースキーム
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        surface: backgroundColor,
        onSurface: textColor,
      ),
      
      // 背景色
      scaffoldBackgroundColor: backgroundColor,
      
      // フォント設定
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.copyWith(
          bodyLarge: const TextStyle(color: textColor),
          bodyMedium: const TextStyle(color: textColor),
          bodySmall: const TextStyle(color: textColor),
          headlineLarge: const TextStyle(color: textColor),
          headlineMedium: const TextStyle(color: textColor),
          headlineSmall: const TextStyle(color: textColor),
          titleLarge: const TextStyle(color: textColor),
          titleMedium: const TextStyle(color: textColor),
          titleSmall: const TextStyle(color: textColor),
          labelLarge: const TextStyle(color: textColor),
          labelMedium: const TextStyle(color: textColor),
          labelSmall: const TextStyle(color: textColor),
          displayLarge: const TextStyle(color: textColor),
          displayMedium: const TextStyle(color: textColor),
          displaySmall: const TextStyle(color: textColor),
        ),
      ),
      
      // AppBarテーマ
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        toolbarHeight: 40, // デフォルトの56から40に変更（SafeAreaを考慮した適切な高さ）
        titleTextStyle: GoogleFonts.notoSansJp(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      useMaterial3: true,
    );
  }
}