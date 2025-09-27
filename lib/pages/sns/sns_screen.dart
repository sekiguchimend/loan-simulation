import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SnsScreen extends HookConsumerWidget {
  const SnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '公式SNSアカウント',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '\\ 最新情報をお届けしています /',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF323232),
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 40),
            
            // YouTube ボタン
            _buildSnsButton(
              context: context,
              url: 'https://www.youtube.com/@daikichi-ir',
              platformName: 'YouTube',
              backgroundImage: 'assets/images/logo_youtube.png',
              colors: [
                const Color(0xFFFF0000),
                const Color(0xFFCC0000),
              ],
              icon: FontAwesomeIcons.youtube,
            ),
            
            const SizedBox(height: 16),
            
            // X ボタン
            _buildSnsButton(
              context: context,
              url: 'https://x.com/daikichi_ir_com',
              platformName: 'X',
              backgroundImage: 'assets/images/logo_x.png',
              colors: [
                const Color(0xFF000000),
                const Color(0xFF333333),
              ],
              icon: FontAwesomeIcons.xTwitter,
            ),
            
            const SizedBox(height: 16),
            
            // Facebook ボタン
            _buildSnsButton(
              context: context,
              url: 'https://www.facebook.com/daikichi.ir',
              platformName: 'Facebook',
              backgroundImage: 'assets/images/logo_facebook.png',
              colors: [
                const Color(0xFF4267B2),
                const Color(0xFF365899),
              ],
              icon: FontAwesomeIcons.facebookF,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSnsButton({
    required BuildContext context,
    required String url,
    required String platformName,
    required String backgroundImage,
    required List<Color> colors,
    required IconData icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.9;
    const buttonHeight = 80.0;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 背景画像（ボタン全体に表示）
            Positioned.fill(
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colors[0],
                  );
                },
              ),
            ),
            
            // グラデーションオーバーレイ（薄く）
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.map((color) => color.withOpacity(0.7)).toList(),
                  ),
                ),
              ),
            ),
            
            // 中央のアイコンとテキスト
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    icon,
                    color: Colors.white,
                    size: 24, // 32から24に縮小
                  ),
                  const SizedBox(height: 6), // スペースも少し縮小
                  Text(
                    platformName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16, // 20から16に縮小
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // タップ処理用の透明レイヤー（最上部）
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _launchUrl(url),
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
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