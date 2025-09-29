import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'home.dart';

class SetupScreen extends HookConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    useEffect(() {
      // Timerを使用してキャンセル可能にする
      final timer = Timer(const Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
      
      // クリーンアップ関数でタイマーをキャンセル
      return () {
        timer.cancel();
      };
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Image.asset(
          'assets/images/daikich_logo.png',
          width: 400,
          height: 250,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF000000),
            );
          },
        ),
      ),
    );
  }
}