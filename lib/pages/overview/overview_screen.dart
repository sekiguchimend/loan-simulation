import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewScreen extends HookConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '会社概要',
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
                  '大吉不動産株式会社について',
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
                  // 上部の画像セクション（gaiyou.jpg + オーバーレイテキスト）
                  Stack(
                    children: [
                      // 背景画像
                      Container(
                        width: double.infinity,
                        height: 220,
                        child: Image.asset(
                          'assets/images/gaiyou.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                            );
                          },
                        ),
                      ),
                      // 暗いオーバーレイ
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      // テキストオーバーレイ
                      Container(
                        width: double.infinity,
                        height: 220,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Company
                            const Text(
                              'Company',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 会社概要
                            const Text(
                              '会社概要',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 赤い横線
                            Container(
                              width: 40,
                              height: 3,
                              color: const Color(0xFFB50303),
                            ),
                            const SizedBox(height: 16),
                            // サブテキスト
                            const Text(
                              '大吉不動産のご紹介',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '会社情報',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 代表挨拶セクション
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        // セクションタイトル
                        const Text(
                          '代表挨拶',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF323232),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 赤い横線
                        Container(
                          width: 40,
                          height: 3,
                          color: const Color(0xFFB50303),
                        ),
                        const SizedBox(height: 24),
                        // 代表の写真
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/daihyou.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.person, size: 80, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 挨拶文
                        const Text(
                          '私が考える不動産とは、不動産投資を通じて経済的に少しでも豊かになる。自分や家族が安心して暮らすための住宅があれば心が豊かになる。と「物」と「心」の両面を豊かにしてくれるものであるはずだと考えています。',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'しかし、不動産業界では昔から騙した騙されたの話が後を絶ちません。',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '弊社ではお客様の不動産購入の失敗を無くしたい、物心の両面で豊かになっていただきたい。という思いで不動産取引、物件に価値の追求をします。全従業員が毎日感謝を忘れず、自分や自社だけ損得勘定だけではなく、人としてどうか、お客様はどうなのかという思いで業務にあたるとともに、お取引に関わる全ての方に「大吉」になっていただけるよう努めてまいります。',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 署名
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '大吉不動産 代表取締役 山本 高昌',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF323232),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 会社概要詳細セクション
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // セクションタイトル
                        const Text(
                          '会社概要',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF323232),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 赤い横線
                        Container(
                          width: 40,
                          height: 3,
                          color: const Color(0xFFB50303),
                        ),
                        const SizedBox(height: 24),
                        // 会社情報テーブル
                        _buildInfoRow('会社名', '大吉不動産株式会社'),
                        _buildInfoRow('代表取締役', '山本 高昌'),
                        _buildInfoRow('所在地', '〒102-0072\n東京都千代田区飯田橋四丁目4番12号\nNBC飯田橋ビル3階'),
                        _buildInfoRow('電話番号', '03-6903-1577（代表）\n03-6709-3099（賃貸管理・入居者様）'),
                        _buildInfoRow('FAX', '03-6903-1588'),
                        _buildInfoRow('MAIL', 'info@daikichi-ir.com'),
                        _buildInfoRow('営業時間', '10:00 – 20:30'),
                        _buildInfoRow('設立', '2013年5月21日'),
                        _buildLinkRow('URL', 'https://daikichi-ir.com/'),
                        _buildInfoRow('事業内容', '不動産投資コンサルティング\n収益不動産の仲介・買取\n収益不動産のリフォーム・リノベーション\n住宅の仲介・買取\n住宅のリフォーム・リノベーション\n賃貸管理'),
                        _buildInfoRow('資本金', '50,000,000円'),
                        _buildInfoRow('宅地建物取引業免許', '東京都知事(2)第101488号'),
                      ],
                    ),
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

  Widget _buildInfoRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF323232),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF323232),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String url) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF323232),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchUrl(url),
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB50303),
                  height: 1.6,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
