// pages/knowleage/widgets/knowleage_tile_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KnowleageTileWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String category;
  final VoidCallback onTap;

  const KnowleageTileWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.onTap,
  });

  Color _getCategoryColor(BuildContext context, String category) {
    // #660F15カラーを使用
    return Color(0xFF660F15);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 88, // ブログカードと同じ高さ
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 画像部分（左端にぴったり配置、1:1のアスペクト比）
                Container(
                  width: 88, // 高さと同じにして1:1の比率（88x88の正方形）
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.article,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // コンテンツ部分（paddingありで適切な配置）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // カテゴリータグ（角ばった形状、#660F15カラー）
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(context, category),
                            borderRadius: BorderRadius.circular(0), // 角ばらせる
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // タイトル
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 矢印アイコン（paddingありで中央寄せ）
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider（左端まで伸ばす）
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey,
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }
}