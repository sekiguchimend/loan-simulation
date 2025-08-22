import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Supabaseクライアント
final supabase = Supabase.instance.client;

// カラム詳細データの状態管理
final columnDetailProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, columnId) async {
  try {
    final response = await supabase
        .from('column_detail')
        .select('*')
        .eq('id', columnId)
        .single();
    
    return response;
  } catch (e) {
    throw Exception('詳細データの取得に失敗しました: $e');
  }
});

class KnowleageDetailScreen extends HookConsumerWidget {
  final int columnId;
  final String title;

  const KnowleageDetailScreen({
    super.key,
    required this.columnId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnDetailAsync = ref.watch(columnDetailProvider(columnId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: columnDetailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
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
                '詳細データの読み込みに失敗しました',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(columnDetailProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (columnDetail) {
          if (columnDetail == null) {
            return const Center(
              child: Text('データが見つかりません'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // メイン画像
                if (columnDetail['image'] != null && columnDetail['image'].isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: CachedNetworkImage(
                      imageUrl: columnDetail['image'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル
                      Text(
                        columnDetail['title'] ?? title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 目次（TOC）
                      if (columnDetail['toc'] != null && columnDetail['toc'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '目次',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                columnDetail['toc'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // コンテンツ
                      if (columnDetail['content'] != null && columnDetail['content'].isNotEmpty)
                        Text(
                          columnDetail['content'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.7,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ボックス画像
                      if (columnDetail['box'] != null && columnDetail['box'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: columnDetail['box'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}