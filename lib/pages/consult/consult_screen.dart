import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 140,
        child: Stack(
          children: [
            // 背景の装飾要素
            _buildBackgroundDecorations(),
            
            // メインコンテンツ
            Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/images/sendarrow.png',
                   width: 250,
                   height: 175,
                   fit: BoxFit.contain,
                 ),
                
                // "contact お問い合わせ" テキスト
                Row(
                  children: [
                    SizedBox(width: 40,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'contact',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFB50303),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Text(
                          'お問い合わせ',
                          style: TextStyle(
                            fontSize: 22,
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
                
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        
        // 黒いボックス（右下）
        Positioned(
          bottom: 220,
          right: 0,
          child: Image.asset(
            'assets/images/box1.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        
        // 灰色のボックス（左下）
        Positioned(
          bottom: 60,
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
  }

  Widget _buildContactText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1行目
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF323232),
                height: 1.6,
                fontWeight: FontWeight.w800
              ),
              children: [
                const TextSpan(
                  text: '詳細な不動産に関するご質問は',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _launchUrl('https://daikichi-ir.com/contact/'),
                    child: Container(
                      child: Text(
                        'こちら',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB50303),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2行目
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF323232),
                height: 1.6,
                fontWeight: FontWeight.w800
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _launchUrl('https://daikichi-ir.com/contact/'),
                    child: Container(
                      child: Text(
                        'のリンク',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB50303),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: 'よりお問い合わせください。',
                ),
              ],
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
}