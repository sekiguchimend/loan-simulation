// loan-simulation/lib/providers/knowledge_providers.dart
// 修正版 - カテゴリーを新しいcategoriesテーブルから取得

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

// カテゴリー一覧を新しいcategoriesテーブルから取得（修正）
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    // アクティブなカテゴリーのみを取得
    final response = await supabase
        .from('categories')
        .select('name')
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .order('name', ascending: true);
    
    // カテゴリー名のリストを作成
    final categories = response
        .map<String>((row) => row['name'] as String)
        .toList();
    
    categories.insert(0, 'すべて');  // 先頭に「すべて」を追加
    
    return categories;
  } catch (e) {
    print('カテゴリー取得エラー: $e');
    // エラー時はcolumnsテーブルからフォールバック取得を試行
    try {
      print('フォールバック: columnsテーブルからカテゴリーを取得中...');
      final fallbackResponse = await supabase
          .from('columns')
          .select('category')
          .eq('is_published', true);
      
      final fallbackCategories = fallbackResponse
          .map<String>((row) => row['category'] as String)
          .toSet()
          .toList();
      
      fallbackCategories.sort();
      fallbackCategories.insert(0, 'すべて');
      
      return fallbackCategories;
    } catch (fallbackError) {
      print('フォールバック取得もエラー: $fallbackError');
      // 最終的なフォールバック：デフォルトカテゴリーを返す
      return ['すべて', '不動産投資', '制度・法律', '買い方', '税金関連'];
    }
  }
});

/// カテゴリーの詳細情報を取得（表示順などが必要な場合）
final categoryDetailsProvider = FutureProvider<List<CategoryDetail>>((ref) async {
  try {
    final response = await supabase
        .from('categories')
        .select('*')
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .order('name', ascending: true);
    
    return response.map<CategoryDetail>((item) => CategoryDetail.fromJson(item)).toList();
  } catch (e) {
    print('カテゴリー詳細取得エラー: $e');
    throw Exception('カテゴリー詳細の取得に失敗しました: $e');
  }
});

/// カテゴリーの詳細情報モデル（ユーザーアプリ用）
class CategoryDetail {
  final int id;
  final String name;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryDetail({
    required this.id,
    required this.name,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json['id'],
      name: json['name'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// カテゴリーと記事数の組み合わせ（統計表示用）
final categoryStatsProvider = FutureProvider<List<CategoryStats>>((ref) async {
  try {
    // カテゴリー一覧を取得
    final categoriesResponse = await supabase
        .from('categories')
        .select('id, name, display_order')
        .eq('is_active', true)
        .order('display_order', ascending: true);
    
    // 各カテゴリーの記事数を取得
    final List<CategoryStats> stats = [];
    
    for (final categoryData in categoriesResponse) {
      final articlesCountResponse = await supabase
          .from('columns')
          .select('id')
          .eq('category', categoryData['name'])
          .eq('is_published', true);
      
      stats.add(CategoryStats(
        id: categoryData['id'],
        name: categoryData['name'],
        displayOrder: categoryData['display_order'] ?? 0,
        articlesCount: articlesCountResponse.length,
      ));
    }
    
    return stats;
  } catch (e) {
    print('カテゴリー統計取得エラー: $e');
    throw Exception('カテゴリー統計の取得に失敗しました: $e');
  }
});

/// カテゴリー統計モデル
class CategoryStats {
  final int id;
  final String name;
  final int displayOrder;
  final int articlesCount;

  CategoryStats({
    required this.id,
    required this.name,
    this.displayOrder = 0,
    required this.articlesCount,
  });

  @override
  String toString() {
    return 'CategoryStats{id: $id, name: $name, displayOrder: $displayOrder, articlesCount: $articlesCount}';
  }
}