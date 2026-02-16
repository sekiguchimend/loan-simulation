// loan-simulation/lib/providers/knowledge_providers.dart
// 修正版 - JOINクエリでカテゴリー名を取得、category_idベースのフィルタリング

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/knowleage/models/knowledge_models.dart';

final supabase = Supabase.instance.client;

// 記事一覧データの状態管理（JOINクエリとcategory_idベースのフィルタリング）
final columnsProvider = FutureProvider.family<List<ArticleColumn>, String?>((ref, category) async {
  try {
    // JOINクエリでカテゴリー名も取得
    var query = supabase
        .from('columns')
        .select('''
          id,
          title,
          image_url,
          url,
          category_id,
          created_at,
          updated_at,
          is_published,
          sort_order,
          categories:category_id (
            id,
            name
          )
        ''');
    
    if (category != null && category != 'すべて') {
      // カテゴリー名からIDを取得してフィルタリング
      try {
        final categoryResponse = await supabase
            .from('categories')
            .select('id')
            .eq('name', category)
            .maybeSingle();
        
        if (categoryResponse != null) {
          final response = await query
              .eq('is_published', true)
              .eq('category_id', categoryResponse['id'])
              .order('sort_order', ascending: true)
              .order('created_at', ascending: false);
          
          return (response as List).map((item) {
            // カテゴリー情報を展開
            final categories = item['categories'] as Map<String, dynamic>?;
            if (categories != null) {
              item['categories'] = categories;
            }
            return ArticleColumn.fromJson(item);
          }).toList();
        } else {
          print('カテゴリー「$category」が見つかりません');
          return [];
        }
      } catch (categoryError) {
        print('カテゴリーフィルタリングエラー: $categoryError');
        // カテゴリーフィルタリングに失敗した場合は全件取得
      }
    }
    
    // すべてまたはカテゴリーフィルタリング失敗時
    final response = await query
        .eq('is_published', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);
    
    return (response as List).map((item) {
      // カテゴリー情報を展開
      final categories = item['categories'] as Map<String, dynamic>?;
      if (categories != null) {
        item['categories'] = categories;
      }
      return ArticleColumn.fromJson(item);
    }).toList();
  } catch (e) {
    print('記事一覧取得エラー: $e');
    throw Exception('データの取得に失敗しました: $e');
  }
});

// 記事詳細データの状態管理（JOINクエリでカテゴリー名も取得）
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
            category_id,
            created_at,
            updated_at,
            is_published,
            sort_order,
            categories:category_id (
              id,
              name
            )
          )
        ''')
        .eq('column_id', columnId)
        .single();
    
    // レスポンス構造を新しいモデルに変換
    final columnData = response['columns'] as Map<String, dynamic>;
    
    // カテゴリー情報を展開
    final categories = columnData['categories'] as Map<String, dynamic>?;
    if (categories != null) {
      columnData['categories'] = categories;
    }
    
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

// カテゴリー一覧を新しいcategoriesテーブルから取得
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    // アクティブなカテゴリーのみを取得
    final response = await supabase
        .from('categories')
        .select('name')
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
    // エラー時はフォールバック
    try {
      print('フォールバック: 代替カテゴリー取得中...');
      
      // 実際に使用されているカテゴリーをJOINで取得
      final fallbackResponse = await supabase
          .from('columns')
          .select('''
            categories:category_id (
              name
            )
          ''')
          .eq('is_published', true);
      
      final fallbackCategories = fallbackResponse
          .map<String>((row) => (row['categories'] as Map<String, dynamic>?)?['name'] as String? ?? '不明')
          .where((name) => name != '不明')
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
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryDetail({
    required this.id,
    required this.name,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json['id'],
      name: json['name'],
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// カテゴリーと記事数の組み合わせ（統計表示用）- JOINクエリ版
final categoryStatsProvider = FutureProvider<List<CategoryStats>>((ref) async {
  try {
    // カテゴリー一覧を取得
    final categoriesResponse = await supabase
        .from('categories')
        .select('id, name, display_order')
        .order('display_order', ascending: true);
    
    // 各カテゴリーの記事数を取得（category_idベース）
    final List<CategoryStats> stats = [];
    
    for (final categoryData in categoriesResponse) {
      final articlesCountResponse = await supabase
          .from('columns')
          .select('id')
          .eq('category_id', categoryData['id']) // category_idで検索
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

/// ヘルパーメソッド：カテゴリー名からIDを取得
Future<int?> getCategoryIdByName(String categoryName) async {
  try {
    final response = await supabase
        .from('categories')
        .select('id')
        .eq('name', categoryName)
        .maybeSingle();
    
    return response?['id'];
  } catch (e) {
    print('カテゴリーID取得エラー: $e');
    return null;
  }
}

/// ヘルパーメソッド：カテゴリーIDからカテゴリー名を取得
Future<String?> getCategoryNameById(int categoryId) async {
  try {
    final response = await supabase
        .from('categories')
        .select('name')
        .eq('id', categoryId)
        .maybeSingle();
    
    return response?['name'];
  } catch (e) {
    print('カテゴリー名取得エラー: $e');
    return null;
  }
}