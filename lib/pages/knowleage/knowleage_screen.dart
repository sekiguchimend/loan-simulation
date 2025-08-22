import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'knowleage_detail_screen.dart';
import 'widgets/knowleage_tile_widget.dart';

// Supabaseクライアント
final supabase = Supabase.instance.client;

// カラムデータの状態管理
final columnsProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, category) async {
  try {
    final query = supabase.from('columns').select('*');
    
    if (category != null && category != 'すべて') {
      final response = await query
          .eq('category', category)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } else {
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
  } catch (e) {
    throw Exception('データの取得に失敗しました: $e');
  }
});

class KnowleageScreen extends HookConsumerWidget {
  const KnowleageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState<String>('すべて');
    
    // カテゴリーリスト
    final categories = ['すべて', '不動産投資', '制度・法律', '買い方', '税金関連'];
    
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
          // カテゴリー選択チップ
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          const Divider(height: 1, color: Colors.grey),
          
          // コンテンツ表示
          Expanded(
            child: columnsAsync.when(
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
                      'データの読み込みに失敗しました',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(columnsProvider);
                      },
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: columns.length,
                  itemBuilder: (context, index) {
                    final column = columns[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: KnowleageTileWidget(
                        title: column['title'] ?? '',
                        imageUrl: column['image'] ?? '',
                        category: column['category'] ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KnowleageDetailScreen(
                                columnId: column['id'],
                                title: column['title'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
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