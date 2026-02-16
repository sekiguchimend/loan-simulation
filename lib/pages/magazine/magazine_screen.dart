// pages/magazine/magazine_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/magazine_providers.dart';
import 'widgets/magazine_card_widget.dart';

class MagazineScreen extends HookConsumerWidget {
  const MagazineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final magazine = ref.watch(magazineProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '大吉マガジン',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 説明部分
          Container(
            width: double.infinity,
            height: 32,
            color: Colors.grey[200],
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '大吉不動産の最新情報をお届け',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w900
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ヘッダーセクション
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Magazine タイトル
                        const Text(
                          'Magazine',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF323232),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 大吉マガジン
                        const Text(
                          '大吉マガジン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF323232),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 赤い横線
                        Container(
                          width: 40,
                          height: 3,
                          color: const Color(0xFFB50303),
                        ),
                        const SizedBox(height: 24),
                        // サブテキスト
                        const Text(
                          '社長の大吉日記、大吉最新NEWSなど',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 説明テキスト
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          '大吉マガジンでは',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF323232),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '不動産投資に関する最新情報や\n社長の大吉日記、大吉最新NEWSなど\nお役立ち情報をお届けしています。',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // マガジンカード
                  magazine.when(
                    data: (mag) => mag != null
                        ? MagazineCardWidget(
                            magazine: mag,
                            onTap: () => _launchUrl(mag.url ?? 'https://daikichi-ir.com/magazine/'),
                          )
                        : const NoMagazineCard(),
                    loading: () => const MagazineCardSkeleton(),
                    error: (error, stack) => _buildMagazineErrorCard(ref),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      print('URL起動エラー: $e');
    }
  }

  Widget _buildMagazineErrorCard(WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Text(
            'マガジンの読み込みに失敗しました',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(magazineProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}
