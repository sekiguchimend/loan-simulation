class SupabaseConfig {
  // 本番環境では環境変数から読み込むことを推奨
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // 開発用フラグ - 本番では false にする
  static const bool isDevelopment = true;
}