// providers/magazine_providers.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/magazine/models/blog_magazine.dart';

final supabase = Supabase.instance.client;

// ブログデータ取得用のProvider
final blogListProvider = FutureProvider<List<BlogMagazine>>((ref) async {
  try {
    print('ブログデータを取得中...');
    
    final response = await supabase
        .from('blogs')
        .select('*')
        .eq('status', false) // ブログのみ取得
        .order('created_at', ascending: false);

    print('ブログデータ取得成功: ${response.length}件');

    final blogs = (response as List)
        .map((item) => BlogMagazine.fromJson(item))
        .toList();

    return blogs;
  } catch (e) {
    print('ブログデータ取得エラー: $e');
    throw Exception('ブログデータの取得に失敗しました: $e');
  }
});

// マガジンデータ取得用のProvider
final magazineProvider = FutureProvider<BlogMagazine?>((ref) async {
  try {
    print('マガジンデータを取得中...');
    
    final response = await supabase
        .from('blogs')
        .select('*')
        .eq('status', true) // マガジンのみ取得
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    print('マガジンデータ取得成功: ${response != null ? "1件" : "0件"}');

    if (response == null) {
      return null;
    }

    return BlogMagazine.fromJson(response);
  } catch (e) {
    print('マガジンデータ取得エラー: $e');
    throw Exception('マガジンデータの取得に失敗しました: $e');
  }
});

// データベース接続テスト用
final databaseConnectionProvider = FutureProvider<bool>((ref) async {
  try {
    await supabase
        .from('blogs')
        .select('count')
        .limit(1);
    
    print('データベース接続テスト成功');
    return true;
  } catch (e) {
    print('データベース接続テスト失敗: $e');
    return false;
  }
});