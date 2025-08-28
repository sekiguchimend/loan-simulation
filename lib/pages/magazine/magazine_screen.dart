// pages/magazine/magazine_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'magazine_detail_screen.dart';
import '../../../config/supabase_config.dart';
import 'widgets/blog_card_widget.dart';
import 'widgets/magazine_card_widget.dart';

final supabase = Supabase.instance.client;

// ブログ/マガジンのモデル
class BlogMagazine {
  final int id;
  final String? title;
  final String? content;
  final String? thumbnail;
  final String? url;
  final bool status; // true: マガジン, false: ブログ
  final DateTime createdAt;

  BlogMagazine({
    required this.id,
    this.title,
    this.content,
    this.thumbnail,
    this.url,
    required this.status,
    required this.createdAt,
  });

  factory BlogMagazine.fromJson(Map<String, dynamic> json) {
    return BlogMagazine(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      url: json['url'],
      status: json['status'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// サンプルデータ
class SampleData {
  static final List<BlogMagazine> sampleBlogs = [
    BlogMagazine(
      id: 1,
      title: 'サンプルタイトル1',
      content: 'これはサンプルブログの内容です。実際のデータがない場合に表示されます。',
      thumbnail: 'https://images.unsplash.com/photo-1560520653-9e0e4c89eb11?w=400&h=300&fit=crop',
      url: null,
      status: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BlogMagazine(
      id: 2,
      title: 'サンプルタイトル2',
      content: 'これは2つ目のサンプルブログです。テスト用の内容が含まれています。',
      thumbnail: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop',
      url: null,
      status: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BlogMagazine(
      id: 3,
      title: 'サンプルタイトル3',
      content: 'これは3つ目のサンプルブログです。開発・テスト用のデータです。',
      thumbnail: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400&h=300&fit=crop',
      url: null,
      status: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  static final BlogMagazine sampleMagazine = BlogMagazine(
    id: 100,
    title: 'サンプルマガジン',
    content: null,
    thumbnail: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop',
    url: 'https://example.com/magazine',
    status: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  );
}

// データ取得用のProvider（サンプルデータフォールバック付き）
final blogListProvider = FutureProvider<List<BlogMagazine>>((ref) async {
  // 開発モードでは常にサンプルデータを使用
  if (SupabaseConfig.isDevelopment) {
    await Future.delayed(const Duration(milliseconds: 800)); // ローディング演出
    return SampleData.sampleBlogs;
  }

  try {
    final response = await supabase
        .from('blogs')
        .select()
        .eq('status', false)
        .order('created_at', ascending: false)
        .limit(3);

    final blogs = (response as List)
        .map((item) => BlogMagazine.fromJson(item))
        .toList();

    // データが空の場合はサンプルデータを返す
    if (blogs.isEmpty) {
      return SampleData.sampleBlogs;
    }

    return blogs;
  } catch (e) {
    // エラーの場合もサンプルデータを返す
    print('ブログデータ取得エラー（サンプルデータを使用）: $e');
    return SampleData.sampleBlogs;
  }
});

final magazineProvider = FutureProvider<BlogMagazine?>((ref) async {
  // 開発モードでは常にサンプルデータを使用
  if (SupabaseConfig.isDevelopment) {
    await Future.delayed(const Duration(milliseconds: 600)); // ローディング演出
    return SampleData.sampleMagazine;
  }

  try {
    final response = await supabase
        .from('blogs')
        .select()
        .eq('status', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      // データがない場合はサンプルデータを返す
      return SampleData.sampleMagazine;
    }

    return BlogMagazine.fromJson(response);
  } catch (e) {
    // エラーの場合もサンプルデータを返す
    print('マガジンデータ取得エラー（サンプルデータを使用）: $e');
    return SampleData.sampleMagazine;
  }
});

class MagazineScreen extends HookConsumerWidget {
  const MagazineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogList = ref.watch(blogListProvider);
    final magazine = ref.watch(magazineProvider);

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
                error: (error, stack) => _buildErrorCard('ブログの読み込みに失敗しました', ref),
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
                  error: (error, stack) => _buildErrorCard('マガジンの読み込みに失敗しました', ref),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.invalidate(blogListProvider);
              ref.invalidate(magazineProvider);
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}