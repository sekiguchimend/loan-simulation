// pages/knowleage/models/knowledge_models.dart

/// 記事の基本情報を表すモデル（columnsテーブル）
class ArticleColumn {
  final int id;
  final String title;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int sortOrder;

  ArticleColumn({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.sortOrder = 0,
  });

  factory ArticleColumn.fromJson(Map<String, dynamic> json) {
    return ArticleColumn(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isPublished: json['is_published'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_published': isPublished,
      'sort_order': sortOrder,
    };
  }

  /// 新規作成用のJSONマップ（IDと自動生成フィールドを除外）
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'is_published': isPublished,
      'sort_order': sortOrder,
    };
  }

  /// 更新用のJSONマップ（IDと作成日時を除外）
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'updated_at': DateTime.now().toIso8601String(),
      'is_published': isPublished,
      'sort_order': sortOrder,
    };
  }

  ArticleColumn copyWith({
    int? id,
    String? title,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? sortOrder,
  }) {
    return ArticleColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// 記事の詳細内容を表すモデル（column_detailsテーブル）
class ColumnDetail {
  final int id;
  final int columnId;
  final String? toc;
  final String content;
  final String? boxImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ColumnDetail({
    required this.id,
    required this.columnId,
    this.toc,
    required this.content,
    this.boxImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColumnDetail.fromJson(Map<String, dynamic> json) {
    return ColumnDetail(
      id: json['id'],
      columnId: json['column_id'],
      toc: json['toc'],
      content: json['content'],
      boxImageUrl: json['box_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'column_id': columnId,
      'toc': toc,
      'content': content,
      'box_image_url': boxImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 新規作成用のJSONマップ（IDと自動生成フィールドを除外）
  Map<String, dynamic> toCreateJson() {
    return {
      'column_id': columnId,
      'toc': toc,
      'content': content,
      'box_image_url': boxImageUrl,
    };
  }

  /// 更新用のJSONマップ（IDと作成日時を除外）
  Map<String, dynamic> toUpdateJson() {
    return {
      'toc': toc,
      'content': content,
      'box_image_url': boxImageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ColumnDetail copyWith({
    int? id,
    int? columnId,
    String? toc,
    String? content,
    String? boxImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ColumnDetail(
      id: id ?? this.id,
      columnId: columnId ?? this.columnId,
      toc: toc ?? this.toc,
      content: content ?? this.content,
      boxImageUrl: boxImageUrl ?? this.boxImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 記事の基本情報と詳細情報を組み合わせたモデル
class KnowledgeArticle {
  final ArticleColumn column;
  final ColumnDetail? detail;

  KnowledgeArticle({
    required this.column,
    this.detail,
  });

  /// Supabaseの結合クエリから作成
  factory KnowledgeArticle.fromJoinedJson(Map<String, dynamic> json) {
    final column = ArticleColumn.fromJson(json);
    
    ColumnDetail? detail;
    if (json['column_details'] != null) {
      if (json['column_details'] is List && (json['column_details'] as List).isNotEmpty) {
        detail = ColumnDetail.fromJson((json['column_details'] as List).first);
      } else if (json['column_details'] is Map) {
        detail = ColumnDetail.fromJson(json['column_details']);
      }
    }

    return KnowledgeArticle(
      column: column,
      detail: detail,
    );
  }

  /// プロバイダーでの結合データから作成
  factory KnowledgeArticle.fromProviderData(Map<String, dynamic> data) {
    return KnowledgeArticle(
      column: ArticleColumn(
        id: data['column_id'] ?? data['id'],
        title: data['title'],
        imageUrl: data['image'],
        category: data['category'],
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.now(), // updatedAtがない場合の代替
        isPublished: true, // デフォルト値
        sortOrder: 0, // デフォルト値
      ),
      detail: ColumnDetail(
        id: data['id'],
        columnId: data['column_id'],
        toc: data['toc'],
        content: data['content'],
        boxImageUrl: data['box'],
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.now(), // updatedAtがない場合の代替
      ),
    );
  }

  /// ID取得用のヘルパー
  int get id => column.id;
  String get title => column.title;
  String? get imageUrl => column.imageUrl;
  String get category => column.category;
  DateTime get createdAt => column.createdAt;
  bool get isPublished => column.isPublished;
  int get sortOrder => column.sortOrder;

  /// 詳細情報のヘルパー
  String? get toc => detail?.toc;
  String? get content => detail?.content;
  String? get boxImageUrl => detail?.boxImageUrl;
  bool get hasDetail => detail != null;

  KnowledgeArticle copyWith({
    ArticleColumn? column,
    ColumnDetail? detail,
  }) {
    return KnowledgeArticle(
      column: column ?? this.column,
      detail: detail ?? this.detail,
    );
  }
}

/// 新規記事作成用のDTO
class CreateKnowledgeArticleDto {
  final String title;
  final String? imageUrl;
  final String category;
  final bool isPublished;
  final int sortOrder;
  final String? toc;
  final String content;
  final String? boxImageUrl;

  CreateKnowledgeArticleDto({
    required this.title,
    this.imageUrl,
    required this.category,
    this.isPublished = true,
    this.sortOrder = 0,
    this.toc,
    required this.content,
    this.boxImageUrl,
  });

  /// Column作成用のデータ
  Map<String, dynamic> toColumnCreateJson() {
    return {
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'is_published': isPublished,
      'sort_order': sortOrder,
    };
  }

  /// ColumnDetail作成用のデータ（columnIdは別途設定）
  Map<String, dynamic> toColumnDetailCreateJson(int columnId) {
    return {
      'column_id': columnId,
      'toc': toc,
      'content': content,
      'box_image_url': boxImageUrl,
    };
  }
}

/// 記事更新用のDTO
class UpdateKnowledgeArticleDto {
  final String? title;
  final String? imageUrl;
  final String? category;
  final bool? isPublished;
  final int? sortOrder;
  final String? toc;
  final String? content;
  final String? boxImageUrl;

  UpdateKnowledgeArticleDto({
    this.title,
    this.imageUrl,
    this.category,
    this.isPublished,
    this.sortOrder,
    this.toc,
    this.content,
    this.boxImageUrl,
  });

  /// Column更新用のデータ
  Map<String, dynamic> toColumnUpdateJson() {
    final Map<String, dynamic> data = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) data['title'] = title;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (category != null) data['category'] = category;
    if (isPublished != null) data['is_published'] = isPublished;
    if (sortOrder != null) data['sort_order'] = sortOrder;

    return data;
  }

  /// ColumnDetail更新用のデータ
  Map<String, dynamic> toColumnDetailUpdateJson() {
    final Map<String, dynamic> data = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (toc != null) data['toc'] = toc;
    if (content != null) data['content'] = content;
    if (boxImageUrl != null) data['box_image_url'] = boxImageUrl;

    return data;
  }

  /// Columnに更新する内容があるかチェック
  bool get hasColumnUpdates => 
      title != null || imageUrl != null || category != null || 
      isPublished != null || sortOrder != null;

  /// ColumnDetailに更新する内容があるかチェック
  bool get hasColumnDetailUpdates => 
      toc != null || content != null || boxImageUrl != null;
}