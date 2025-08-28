// lib/providers/knowledge_providers.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabaseクライアント
final supabase = Supabase.instance.client;

// 記事一覧データの状態管理
final columnsProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, category) async {
  try {
    // クエリの基本形を作成
    final query = supabase
        .from('columns')
        .select('id, title, image_url, category, created_at');
    
    // 公開済みのものだけを取得し、カテゴリーでフィルタリング
    if (category != null && category != 'すべて') {
      final response = await query
          .eq('is_published', true)
          .eq('category', category)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } else {
      final response = await query
          .eq('is_published', true)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
  } catch (e) {
    print('データベース接続エラー: $e');
    throw Exception('データの取得に失敗しました: $e');
  }
});

// 記事詳細データの状態管理
final columnDetailProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, columnId) async {
  try {
    // JOINを使って関連データを一度に取得
    final response = await supabase
        .from('column_details')
        .select('''
          *,
          columns:column_id (
            title,
            image_url,
            category,
            created_at
          )
        ''')
        .eq('column_id', columnId)
        .single();
    
    // レスポンス構造をフラット化
    final columnData = response['columns'] as Map<String, dynamic>;
    return {
      'id': response['id'],
      'column_id': response['column_id'],
      'title': columnData['title'],
      'image': columnData['image_url'],
      'category': columnData['category'],
      'created_at': columnData['created_at'],
      'toc': response['toc'],
      'content': response['content'],
      'box': response['box_image_url'],
    };
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