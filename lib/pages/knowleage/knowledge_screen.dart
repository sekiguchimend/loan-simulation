// pages/knowleage/knowleage_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../providers/knowledge_providers.dart'; // プロバイダーをインポート
import 'knowledge_detail_screen.dart';
import 'widgets/knowleage_tile_widget.dart';
import 'sample/sample_data.dart';

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
      body: Column(
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
                // エラー時はデフォルトカテゴリーを表示
                final defaultCategories = ['すべて', '不動産投資', '制度・法律', '買い方', '税金関連'];
                return Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: defaultCategories.length,
                        itemBuilder: (context, index) {
                          final category = defaultCategories[index];
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
              },
              data: (categories) => Row(
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
              ),
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
                // エラー時はサンプルデータを使用
                print('データベース接続エラー、サンプルデータを表示: $error');
                final sampleColumns = SampleData.getSampleColumns();
                final filteredColumns = selectedCategory.value == 'すべて' 
                    ? sampleColumns
                    : sampleColumns.where((column) => column['category'] == selectedCategory.value).toList();
                
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredColumns.length,
                  itemBuilder: (context, index) {
                    final column = filteredColumns[index];
                    return KnowleageTileWidget(
                      title: column['title'] ?? '',
                      imageUrl: column['image'] ?? '',
                      category: column['category'] ?? '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => KnowleageDetailScreen(
                              columnId: column['id'],
                              title: column['title'] ?? '',
                              category: column['category'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              data: (columns) {
                if (columns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'まだ記事がありません',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: columns.length,
                  itemBuilder: (context, index) {
                    final column = columns[index];
                    return KnowleageTileWidget(
                      title: column['title'] ?? '',
                      imageUrl: column['image_url'] ?? '', // 新しいフィールド名
                      category: column['category'] ?? '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => KnowleageDetailScreen(
                              columnId: column['id'],
                              title: column['title'] ?? '',
                              category: column['category'] ?? '',
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
    );
  }
}