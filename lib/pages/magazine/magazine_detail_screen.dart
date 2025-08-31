// pages/magazine/magazine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/blog_magazine.dart';
import '../../providers/magazine_providers.dart';
import 'widgets/magazine_card_widget.dart';

class MagazineDetailScreen extends HookConsumerWidget {
  final BlogMagazine blog;

  const MagazineDetailScreen({
    super.key,
    required this.blog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final magazine = ref.watch(magazineProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('大吉マガジン'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日付（左上、黒文字）
                  Text(
                    _formatDate(blog.createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Staff Blogラベル（背景黒）
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Staff Blog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // タイトル（小さめ）
                  Text(
                    blog.title ?? 'タイトルなし',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  // const SizedBox(height: 12),
                ],
              ),
            ),
            
            // 画像
            _buildHeaderImage(),
            
            const SizedBox(height: 20),
            
            // 本文
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(),
            ),
            
            const SizedBox(height: 32),
            
            // マガジンセクション
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: magazine.when(
                data: (mag) => mag != null 
                    ? MagazineCardWidget(
                        magazine: mag,
                        onTap: () => _launchMagazine(mag.url),
                      )
                    : const NoMagazineCard(),
                loading: () => const MagazineCardSkeleton(),
                error: (error, stack) => _buildMagazineErrorCard('マガジンの読み込みに失敗しました', error.toString(), ref),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: blog.thumbnail != null && blog.thumbnail!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: blog.thumbnail!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            '画像なし',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (blog.content == null || blog.content!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'コンテンツがありません',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // シンプルなテキスト表示（白いボックスなし）
    return Text(
      blog.content!,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }

  Widget _buildMagazineErrorCard(String message, String errorDetails, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 200,
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
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _launchMagazine(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }
    
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('URL起動エラー: $e');
    }
  }
}