import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SnsLink {
  final String platform;
  final String url;
  final bool isActive;
  final int sortOrder;

  SnsLink({
    required this.platform,
    required this.url,
    required this.isActive,
    required this.sortOrder,
  });

  factory SnsLink.fromJson(Map<String, dynamic> json) {
    return SnsLink(
      platform: json['platform'] as String,
      url: json['url'] as String,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

/// SNSリンク一覧を取得するProvider
final snsLinksProvider = FutureProvider<List<SnsLink>>((ref) async {
  try {
    final response = await supabase
        .from('sns_links')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((item) => SnsLink.fromJson(item))
        .toList();
  } catch (e) {
    print('SNSリンク取得エラー: $e');
    return [];
  }
});

/// プラットフォーム名でURLを取得するヘルパー
String? getSnsUrl(List<SnsLink> links, String platform) {
  try {
    return links.firstWhere((l) => l.platform == platform).url;
  } catch (_) {
    return null;
  }
}
