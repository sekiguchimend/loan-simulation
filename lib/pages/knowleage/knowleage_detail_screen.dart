import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'sample/sample_data.dart';

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
  final String? category;

  const KnowleageDetailScreen({
    super.key,
    required this.columnId,
    required this.title,
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnDetailAsync = ref.watch(columnDetailProvider(columnId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '不動産の知識',
          style: TextStyle(
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
        error: (error, stackTrace) {
          // エラー時はサンプルデータを使用
          final sampleDetail = SampleData.getSampleColumnDetailById(columnId);
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // カテゴリーチップ（画面左上）
                      if ((sampleDetail!['category'] != null && sampleDetail['category'].isNotEmpty) || 
                          (category != null && category!.isNotEmpty))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            sampleDetail['category'] ?? category ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // タイトル
                      Text(
                        sampleDetail['title'] ?? title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // メイン画像
                if (sampleDetail['image'] != null && sampleDetail['image'].isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: CachedNetworkImage(
                      imageUrl: sampleDetail['image'],
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
                      // 目次（TOC）
                      if (sampleDetail['toc'] != null && sampleDetail['toc'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '目次',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sampleDetail['toc'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (sampleDetail['toc'] != null && sampleDetail['toc'].isNotEmpty)
                        const SizedBox(height: 20),

                      // コンテンツ
                      if (sampleDetail['content'] != null && sampleDetail['content'].isNotEmpty)
                        Text(
                          sampleDetail['content'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.7,
                          ),
                        ),

                      if (sampleDetail['content'] != null && sampleDetail['content'].isNotEmpty)
                        const SizedBox(height: 20),

                      // ボックス画像
                      if (sampleDetail['box'] != null && sampleDetail['box'].isNotEmpty)
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
                              imageUrl: sampleDetail['box'],
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // カテゴリーチップ（画面左上）
                      if ((columnDetail['category'] != null && columnDetail['category'].isNotEmpty) || 
                          (category != null && category!.isNotEmpty))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            columnDetail['category'] ?? category ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
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
                    ],
                  ),
                ),

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
                      // 目次（TOC）
                      if (columnDetail['toc'] != null && columnDetail['toc'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '目次',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                columnDetail['toc'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (columnDetail['toc'] != null && columnDetail['toc'].isNotEmpty)
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

                      if (columnDetail['content'] != null && columnDetail['content'].isNotEmpty)
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