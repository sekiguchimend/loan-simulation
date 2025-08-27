import 'package:flutter/material.dart';
import '../magazine_screen.dart'; // BlogMagazineモデルをインポート

class BlogCardWidget extends StatelessWidget {
  final BlogMagazine blog;
  final VoidCallback onTap;

  const BlogCardWidget({
    super.key,
    required this.blog,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 88, // カードの高さを88pxに設定
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // サムネイル（1:1の縦横比、paddingなしで縦幅全体に広がる）
                Container(
                  width: 88, // 高さと同じにして1:1の比率に（88x88の正方形）
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: blog.thumbnail != null && blog.thumbnail!.isNotEmpty
                      ? Image.network(
                          blog.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 28,
                            );
                          },
                        )
                      : Icon(
                          Icons.article,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // コンテンツ（paddingありで適切な配置）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Staff Blogラベル
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Text(
                            'Staff Blog',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // 日付
                        Text(
                          _formatDate(blog.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // タイトル
                        Expanded(
                          child: Text(
                            blog.title ?? 'タイトルなし',
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class BlogCardSkeleton extends StatelessWidget {
  const BlogCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 88, // カードの高さに合わせて88pxに
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 88, // 1:1の正方形（88x88）
                color: Colors.grey[300],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 180,
                              height: 12,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
        ),
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

class NoBlogCard extends StatelessWidget {
  const NoBlogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'まだブログがありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}