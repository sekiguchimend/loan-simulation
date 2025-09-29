// pages/magazine/models/blog_magazine.dart

class BlogMagazine {
  final int id;
  final String? title;
  final String? content;
  final String? thumbnail;
  final String? url;
  final bool status; // true: マガジン, false: ブログ
  final DateTime createdAt;

  BlogMagazine({
    required this.id,
    this.title,
    this.content,
    this.thumbnail,
    this.url,
    required this.status,
    required this.createdAt,
  });

  factory BlogMagazine.fromJson(Map<String, dynamic> json) {
    return BlogMagazine(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      url: json['url'],
      status: json['status'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'thumbnail': thumbnail,
      'url': url,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}