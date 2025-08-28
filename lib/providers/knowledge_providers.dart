// providers/knowledge_providers.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/knowleage/models/knowledge_models.dart';

final supabase = Supabase.instance.client;

// 記事一覧データの状態管理
final columnsProvider = FutureProvider.family<List<ArticleColumn>, String?>((ref, category) async {
  try {
    var query = supabase
        .from('columns')
        .select('id, title, image_url, category, created_at, updated_at, is_published, sort_order');
    
    // 公開済みのものだけを取得し、カテゴリーでフィルタリング
    if (category != null && category != 'すべて') {
      final response = await query
          .eq('is_published', true)
          .eq('category', category)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);
      return (response as List).map((item) => ArticleColumn.fromJson(item)).toList();
    } else {
      final response = await query
          .eq('is_published', true)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);
      return (response as List).map((item) => ArticleColumn.fromJson(item)).toList();
    }
  } catch (e) {
    print('データベース接続エラー: $e');
    throw Exception('データの取得に失敗しました: $e');
  }
});

// 記事詳細データの状態管理
final columnDetailProvider = FutureProvider.family<KnowledgeArticle?, int>((ref, columnId) async {
  try {
    // JOINを使って関連データを一度に取得
    final response = await supabase
        .from('column_details')
        .select('''
          *,
          columns:column_id (
            id,
            title,
            image_url,
            category,
            created_at,
            updated_at,
            is_published,
            sort_order
          )
        ''')
        .eq('column_id', columnId)
        .single();
    
    // レスポンス構造を新しいモデルに変換
    final columnData = response['columns'] as Map<String, dynamic>;
    final column = ArticleColumn.fromJson(columnData);
    
    final detail = ColumnDetail(
      id: response['id'],
      columnId: response['column_id'],
      toc: response['toc'],
      content: response['content'],
      boxImageUrl: response['box_image_url'],
      createdAt: DateTime.parse(response['created_at']),
      updatedAt: DateTime.parse(response['updated_at']),
    );

    return KnowledgeArticle(column: column, detail: detail);
  } catch (e) {
    print('詳細データベース接続エラー: $e');
    throw Exception('詳細データの取得に失敗しました: $e');
  }
});

// カテゴリー一覧を動的に取得
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final response = await supabase
        .from('columns')
        .select('category')
        .eq('is_published', true);
    
    // 重複を除去してソート
    final categories = response
        .map<String>((row) => row['category'] as String)
        .toSet()
        .toList();
    
    categories.sort();
    categories.insert(0, 'すべて');  // 先頭に「すべて」を追加
    
    return categories;
  } catch (e) {
    print('カテゴリー取得エラー: $e');
    // エラー時はデフォルトカテゴリーを返す
    return ['すべて', '不動産投資', '制度・法律', '買い方', '税金関連'];
  }
});