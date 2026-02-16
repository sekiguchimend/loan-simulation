import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ConsultScreen extends HookConsumerWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ご相談',
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
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'お問い合わせ・公式SNS',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 上部のヒーローセクション
                  Stack(
                    children: [
                      // 背景画像
                      Container(
                        width: double.infinity,
                        height: 180,
                        child: Image.asset(
                          'assets/images/sendarrow.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1a1a1a),
                            );
                          },
                        ),
                      ),
                      // 暗いオーバーレイ
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF1a1a1a).withOpacity(0.95),
                              const Color(0xFF2a2a2a).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                      // テキストオーバーレイ
                      Container(
                        width: double.infinity,
                        height: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Contact
                            const Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // お問い合わせ
                            const Text(
                              'お問い合わせ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 赤い横線
                            Container(
                              width: 40,
                              height: 3,
                              color: const Color(0xFFB50303),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 白い背景のコンテンツ部分
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 説明文
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF323232),
                              height: 1.8,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(
                                text: '不動産投資や物件に関するご質問・ご相談は',
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _launchUrl('https://daikichi-ir.com/contact/'),
                                  child: const Text(
                                    '「こちらのリンク」',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFFB50303),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                text: 'よりお気軽にお問い合わせください。専門スタッフが丁寧にご対応いたします。',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SNSセクション
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '公式SNS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF323232),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 3,
                          color: const Color(0xFFB50303),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '最新情報をチェック',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SNSボタングリッド（縦幅半分）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 2.5,
                      children: [
                        _buildSnsButton(
                          context: context,
                          url: 'https://x.com/daikichi_ir_com',
                          platformName: 'X',
                          colors: [
                            const Color(0xFF000000),
                            const Color(0xFF333333),
                          ],
                          icon: FontAwesomeIcons.xTwitter,
                        ),
                        _buildSnsButton(
                          context: context,
                          url: 'https://www.youtube.com/@daikichi-ir',
                          platformName: 'YouTube',
                          colors: [
                            const Color(0xFFD32F2F),
                            const Color(0xFFC62828),
                          ],
                          icon: FontAwesomeIcons.youtube,
                        ),
                        _buildSnsButton(
                          context: context,
                          url: 'https://line.me/R/ti/p/@daikichi',
                          platformName: 'LINE',
                          colors: [
                            const Color(0xFF06C755),
                            const Color(0xFF00B140),
                          ],
                          icon: FontAwesomeIcons.line,
                        ),
                        _buildSnsButton(
                          context: context,
                          url: 'https://www.facebook.com/daikichi.ir',
                          platformName: 'Facebook',
                          colors: [
                            const Color(0xFF4267B2),
                            const Color(0xFF365899),
                          ],
                          icon: FontAwesomeIcons.facebookF,
                        ),
                        _buildSnsButton(
                          context: context,
                          url: 'https://www.tiktok.com/@daikichi.ir',
                          platformName: 'TikTok',
                          colors: [
                            const Color(0xFF000000),
                            const Color(0xFF333333),
                          ],
                          icon: FontAwesomeIcons.tiktok,
                        ),
                        _buildSnsButton(
                          context: context,
                          url: 'https://www.instagram.com/daikichi.ir/',
                          platformName: 'Instagram',
                          colors: [
                            const Color(0xFF833AB4),
                            const Color(0xFFF77737),
                          ],
                          icon: FontAwesomeIcons.instagram,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnsButton({
    required BuildContext context,
    required String url,
    required String platformName,
    required List<Color> colors,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  platformName,
                  style: const TextStyle(
                    fontFamily: 'NotoSansJP',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchUrl(url),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(),
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
}
