// lib/config/supabase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // フォールバック付きの安全な設定読み込み
  static String get supabaseUrl {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      if (url != null && url.isNotEmpty) {
        return url;
      }
    } catch (e) {
      print('環境変数の読み込みエラー: $e');
    }
    
    // フォールバック値（開発用）
    return 'https://kraphscapmsgngcttizt.supabase.co';
  }
  
  static String get supabaseAnonKey {
    try {
      final key = dotenv.env['SUPABASE_ANON_KEY'];
      if (key != null && key.isNotEmpty) {
        return key;
      }
    } catch (e) {
      print('環境変数の読み込みエラー: $e');
    }
    
    // フォールバック値（開発用）
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyYXBoc2NhcG1zZ25nY3R0aXp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4ODEwNzksImV4cCI6MjA3MDQ1NzA3OX0.zrYzOY9efKaIhDlqASfJYzszcV2EAtIKJOFUWTdSdq0';
  }
  
  // 開発用フラグ
  static const bool isDevelopment = true;
  
  // 環境変数が読み込まれているかチェック
  static bool get isEnvLoaded {
    try {
      return dotenv.isInitialized;
    } catch (e) {
      return false;
    }
  }
}