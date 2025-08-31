// pages/magazine/magazine_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/blog_magazine.dart';
import '../../providers/magazine_providers.dart';
import 'magazine_detail_screen.dart';
import 'widgets/blog_card_widget.dart';
import 'widgets/magazine_card_widget.dart';

class MagazineScreen extends HookConsumerWidget {
  const MagazineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogList = ref.watch(blogListProvider);
    final magazine = ref.watch(magazineProvider);
    final dbConnection = ref.watch(databaseConnectionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(blogListProvider);
          ref.invalidate(magazineProvider);
          ref.invalidate(databaseConnectionProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 説明部分
              Container(
                width: double.infinity,
                height: 32,
                color: Colors.grey[200],
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '社長の大吉日記、大吉最新NEWSなど',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  ),
              ),



              // ブログリスト（パディングなし）
              blogList.when(
                data: (blogs) => blogs.isEmpty 
                    ? const NoBlogCard()
                    : Column(
                        children: blogs.map((blog) => BlogCardWidget(
                          blog: blog,
                          onTap: () => _navigateToBlogDetail(context, blog),
                        )).toList(),
                      ),
                loading: () => const Column(
                  children: [
                    BlogCardSkeleton(),
                    BlogCardSkeleton(),
                    BlogCardSkeleton(),
                  ],
                ),
                error: (error, stack) => _buildBlogErrorCard('ブログの読み込みに失敗しました', error.toString(), ref),
              ),
              
              const SizedBox(height: 24),
              
              // マガジンセクション（パディングあり）
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
      ),
    );
  }

  Widget _buildBlogErrorCard(String message, String errorDetails, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
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
            const SizedBox(height: 8),
            Text(
              'データベースへの接続に問題が発生している可能性があります',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(blogListProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
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

  void _navigateToBlogDetail(BuildContext context, BlogMagazine blog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MagazineDetailScreen(blog: blog),
      ),
    );
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