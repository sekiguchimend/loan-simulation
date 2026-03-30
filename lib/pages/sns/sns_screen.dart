import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/sns_providers.dart';

class SnsScreen extends HookConsumerWidget {
  const SnsScreen({super.key});

  // プラットフォームごとの表示設定
  static const _platformConfigs = {
    'x': _PlatformConfig('X', FontAwesomeIcons.xTwitter, 'assets/images/logo_x.png', [Color(0xFF000000), Color(0xFF333333)], 0.5),
    'youtube': _PlatformConfig('YouTube', FontAwesomeIcons.youtube, 'assets/images/logo_youtube.png', [Color(0xFFD32F2F), Color(0xFFC62828)], 0.95),
    'line': _PlatformConfig('LINE', FontAwesomeIcons.line, 'assets/images/line.png', [Color(0xFF06C755), Color(0xFF00B140)], 0.95),
    'facebook': _PlatformConfig('Facebook', FontAwesomeIcons.facebookF, 'assets/images/logo_facebook.png', [Color(0xFF4267B2), Color(0xFF365899)], 0.95),
    'tiktok': _PlatformConfig('TikTok', FontAwesomeIcons.tiktok, 'assets/images/box1.png', [Color(0xFF000000), Color(0xFF333333)], 0.5),
    'instagram': _PlatformConfig('Instagram', FontAwesomeIcons.instagram, 'assets/images/box1.png', [Color(0xFF833AB4), Color(0xFFF77737)], 0.95),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snsLinksAsync = ref.watch(snsLinksProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final topSpacing = isSmallScreen ? 16.0 : 40.0;
    final horizontalPadding = isSmallScreen ? 40.0 : 28.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '公式SNSアカウント',
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
                  '公式SNSで最新情報をチェック',
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
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  SizedBox(height: topSpacing),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: CustomPaint(
                        painter: SpeechBubblePainter(),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                          alignment: Alignment.center,
                          child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: fontSize,
                              color: Color(0xFF323232),
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: '不動産情報',
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: titleFontSize,
                                  color: Color(0xFFC41E3A),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(text: 'をお届けしています !'),
                            ],
                          ),
                        ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),

            // 2列グリッドでSNSボタンを表示
            snsLinksAsync.when(
              data: (links) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.25,
                children: links
                    .where((link) => _platformConfigs.containsKey(link.platform))
                    .map((link) {
                  final config = _platformConfigs[link.platform]!;
                  return _buildSnsButton(
                    context: context,
                    url: link.url,
                    platformName: config.name,
                    backgroundImage: config.backgroundImage,
                    colors: config.colors,
                    icon: config.icon,
                    opacity: config.opacity,
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
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

  Widget _buildSnsButton({
    required BuildContext context,
    required String url,
    required String platformName,
    required String backgroundImage,
    required List<Color> colors,
    required IconData icon,
    double opacity = 0.9,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            // 背景画像（ボタン全体に表示）
            Positioned.fill(
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.contain,
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
                    colors: colors.map((color) => color.withOpacity(opacity)).toList(),
                  ),
                ),
              ),
            ),

            // 中央のアイコンとテキスト
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    platformName,
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
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

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Color(0xFF323232)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final radius = 12.0;
    final nipHeight = 12.0;
    final nipWidth = 20.0;

    final path = Path();

    // 左上から開始
    path.moveTo(radius, 0);
    // 上辺
    path.lineTo(size.width - radius, 0);
    // 右上の角
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
    );
    // 右辺
    path.lineTo(size.width, size.height - nipHeight - radius);
    // 右下の角
    path.arcToPoint(
      Offset(size.width - radius, size.height - nipHeight),
      radius: Radius.circular(radius),
    );
    // 下辺（右から中央へ）
    path.lineTo(size.width / 2 + nipWidth / 2, size.height - nipHeight);
    // 吹き出しの三角形（下向き）
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 - nipWidth / 2, size.height - nipHeight);
    // 下辺（中央から左へ）
    path.lineTo(radius, size.height - nipHeight);
    // 左下の角
    path.arcToPoint(
      Offset(0, size.height - nipHeight - radius),
      radius: Radius.circular(radius),
    );
    // 左辺
    path.lineTo(0, radius);
    // 左上の角
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
    );

    path.close();

    // 影
    canvas.save();
    canvas.translate(2, 3);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 塗りつぶし
    canvas.drawPath(path, paint);
    // 枠線
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PlatformConfig {
  final String name;
  final IconData icon;
  final String backgroundImage;
  final List<Color> colors;
  final double opacity;

  const _PlatformConfig(this.name, this.icon, this.backgroundImage, this.colors, this.opacity);
}
