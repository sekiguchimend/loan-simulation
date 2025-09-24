import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'home.dart';

class SetupScreen extends HookConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // 3秒後にフェード効果でホーム画面に遷移
      final timer = Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // フェードアウト・フェードイン効果
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800), // 0.8秒でフェード
            ),
          );
        }
      });
      
      return () {
        // タイマーのクリーンアップは自動的に行われる
      };
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Image.asset(
          'assets/images/daikichi_logo.png',
          width: 300,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // 画像が見つからない場合は黒画面を表示
            return Container(
              color: const Color(0xFF000000),
            );
          },
        ),
      ),
    );
  }
}