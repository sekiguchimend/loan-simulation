import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';

class ConsultScreen extends HookConsumerWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'お問い合わせ',
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
          // 説明部分（ヘッダー下の装飾）
          Container(
            width: double.infinity,
            height: 32,
            color: Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '大吉最新NEWSなど',
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
            child: Stack(
              children: [
                // メインコンテンツ
                Positioned.fill(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/sendarrow.png',
                              width: 150,
                              height: 105,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 250,
                                  height: 175,
                                  color: Colors.transparent,
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // "contact お問い合わせ" テキスト
                            Row(
                              children: [
                                const SizedBox(width: 40),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'contact',
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Color(0xFFB50303),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      'お問い合わせ',
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // 説明文とリンク
                            _buildContactText(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 背景の装飾要素
                _buildBackgroundDecorations(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;

        return Stack(
          children: [
            // 黒いボックス（右上寄り - contactテキストの近く）
            Positioned(
              top: screenHeight * 0.30,
          right: 0,
          child: Image.asset(
            'assets/images/box1.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        
        // 灰色のボックス（左下寄り - 最後のコンテンツの近く）
        Positioned(
          top: screenHeight * 0.75,
          left: 0,
          child: Image.asset(
            'assets/images/box2.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildContactText(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1行目
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF323232),
                    height: 1.8,
                    fontWeight: FontWeight.w800
                  ),
                  children: [
                    const TextSpan(
                      text: '不動産投資や物件に関する',
                    ),
                  ],
                ),
              ),
              // 2行目
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF323232),
                    height: 1.8,
                    fontWeight: FontWeight.w800
                  ),
                  children: [
                    const TextSpan(
                      text: 'ご質問・ご相談は',
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _launchUrl('https://daikichi-ir.com/contact/'),
                        child: const Text(
                          'こちらのリンク',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB50303),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text: 'より',
                    ),
                  ],
                ),
              ),
              // 3行目
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF323232),
                    height: 1.8,
                    fontWeight: FontWeight.w800
                  ),
                  children: [
                    const TextSpan(
                      text: 'お気軽にお問い合わせください。',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 4行目
              RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF323232),
                    height: 1.8,
                    fontWeight: FontWeight.w800
                  ),
                  children: [
                    TextSpan(
                      text: '専門スタッフが丁寧にご対応いたします。',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
}