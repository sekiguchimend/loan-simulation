import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; ← 削除

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
      
      // デフォルトフォントをNotoSansJPに設定
      fontFamily: 'NotoSansJP',
      
      // フォント設定
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyLarge: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        bodyMedium: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        bodySmall: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        headlineLarge: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        headlineMedium: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        headlineSmall: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        titleLarge: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        titleMedium: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        titleSmall: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        labelLarge: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        labelMedium: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        labelSmall: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        displayLarge: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        displayMedium: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
        displaySmall: const TextStyle(color: textColor, fontFamily: 'NotoSansJP'),
      ),
      
      // AppBarテーマ
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        toolbarHeight: 40, // デフォルトの56から40に変更（SafeAreaを考慮した適切な高さ）
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'NotoSansJP',
        ),
      ),
      
      useMaterial3: true,
    );
  }
}