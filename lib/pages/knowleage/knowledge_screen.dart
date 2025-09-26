// loan-simulation/lib/pages/knowleage/knowledge_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../providers/knowledge_providers.dart';
import 'knowledge_detail_screen.dart';
import 'widgets/knowleage_tile_widget.dart';

class KnowleageScreen extends HookConsumerWidget {
  const KnowleageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState<String>('すべて');
    
    // 動的にカテゴリーをデータベースから取得
    final categoriesAsync = ref.watch(categoriesProvider);
    
    // カラムデータの取得
    final columnsAsync = ref.watch(columnsProvider(
      selectedCategory.value == 'すべて' ? null : selectedCategory.value
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '不動産の知識',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(columnsProvider(
            selectedCategory.value == 'すべて' ? null : selectedCategory.value
          ));
        },
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
                    '不動産と資産運用のお役立ち情報',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ),
              ),
            ),
            
            // カテゴリー選択チップ
            Container(
              height: 60,
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  print('カテゴリー取得エラー: $error');
                  // エラー時はデフォルトカテゴリーを表示
                  final defaultCategories = ['すべて', '不動産投資', '制度・法律', '買い方', '税金関連'];
                  return _buildCategoryChips(context, defaultCategories, selectedCategory);
                },
                data: (categories) {
                  print('カテゴリー一覧取得成功: $categories'); // デバッグ情報
                  return _buildCategoryChips(context, categories, selectedCategory);
                },
              ),
            ),
            
            const Divider(height: 1, color: Colors.grey),
            
            // コンテンツ表示
            Expanded(
              child: columnsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  print('記事データ取得エラー: $error');
                  return _buildErrorCard('記事の読み込みに失敗しました', error.toString(), ref, selectedCategory.value);
                },
                data: (columns) {
                  print('記事一覧取得成功: ${columns.length}件'); // デバッグ情報
                  if (columns.isNotEmpty) {
                    // nullセーフなデバッグ情報
                    print('最初の記事のカテゴリー情報: categoryId=${columns[0].categoryId ?? "null"}, categoryName=${columns[0].categoryName ?? "null"}');
                  }
                  
                  if (columns.isEmpty) {
                    return _buildNoDataCard();
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: columns.length,
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return KnowleageTileWidget(
                        title: column.title,
                        imageUrl: column.imageUrl ?? '',
                        category: column.category, // 後方互換性プロパティを使用
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KnowleageDetailScreen(
                                columnId: column.id,
                                title: column.title,
                                category: column.category,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
    BuildContext context, 
    List<String> categories, 
    ValueNotifier<String> selectedCategory
  ) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory.value == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    print('カテゴリー選択: $category'); // デバッグ情報
                    selectedCategory.value = category;
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNoDataCard() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '記事がありません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, String errorDetails, WidgetRef ref, String selectedCategory) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'データベースへの接続に問題が発生している可能性があります。',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(categoriesProvider);
                  ref.invalidate(columnsProvider(
                    selectedCategory == 'すべて' ? null : selectedCategory
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  '再試行',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}