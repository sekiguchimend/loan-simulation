import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'setup_screen.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Fontsをプリキャッシュ
  // await Future.wait([
  //   precacheGoogleFont(GoogleFonts.notoSansJp(fontWeight: FontWeight.w700)),
  //   precacheGoogleFont(GoogleFonts.notoSansJp(fontWeight: FontWeight.w800)),
  //   precacheGoogleFont(GoogleFonts.notoSansJp(fontWeight: FontWeight.w900)),
  // ]);

  // .envファイルの読み込みを試行
  try {
    await dotenv.load(fileName: ".env");
    print('.envファイルの読み込み成功');
  } catch (e) {
    print('.envファイルの読み込みエラー（フォールバック値を使用）: $e');
  }

  // Supabaseの初期化
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    print('Supabaseの初期化完了');
    print('環境変数読み込み状況: ${SupabaseConfig.isEnvLoaded ? "成功" : "フォールバック使用"}');
  } catch (e) {
    print('Supabaseの初期化エラー: $e');
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Future<void> precacheGoogleFont(TextStyle style) async {
//   try {
//     await GoogleFonts.pendingFonts([style]);
//   } catch (e) {
//     print('Font preload error: $e');
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan-Simulation',
      theme: AppTheme.lightTheme,
      home: const SetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}