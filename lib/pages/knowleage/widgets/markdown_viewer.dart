// loan-simulation/lib/pages/knowleage/widgets/markdown_viewer.dart
// ユーザーアプリ用Markdownビューアー（エラー修正版）

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserMarkdownViewer extends StatelessWidget {
  final String markdownContent;
  final EdgeInsets? padding;

  const UserMarkdownViewer({
    Key? key,
    required this.markdownContent,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      child: MarkdownBody(
        data: markdownContent.isEmpty ? '' : markdownContent,
        styleSheet: _getStyleSheet(context),
        onTapLink: (text, href, title) => _handleLinkTap(href),
        imageBuilder: (uri, title, altText) => _buildImage(uri, title, altText),
        selectable: true,
      ),
    );
  }

  MarkdownStyleSheet _getStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    return MarkdownStyleSheet(
      // 見出しスタイル
      h1: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
        height: 1.4,
      ),
      h2: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor.withOpacity(0.9),
        height: 1.4,
      ),
      h3: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor.withOpacity(0.8),
        height: 1.4,
      ),
      h4: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor.withOpacity(0.7),
        height: 1.4,
      ),
      h5: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor.withOpacity(0.6),
        height: 1.4,
      ),
      h6: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor.withOpacity(0.5),
        height: 1.4,
      ),
      
      // 本文スタイル
      p: const TextStyle(
        fontSize: 16,
        height: 1.7,
        color: Colors.black87,
      ),
      
      // リンクスタイル
      a: TextStyle(
        color: theme.primaryColor,
        decoration: TextDecoration.underline,
      ),
      
      // リストスタイル（修正版）
      listBullet: TextStyle(
        fontSize: 16,
        color: theme.primaryColor,
      ),
      
      // 引用スタイル
      blockquote: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.grey[700],
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(
            color: theme.primaryColor,
            width: 4,
          ),
        ),
      ),
      
      // コードスタイル
      code: TextStyle(
        fontSize: 14,
        fontFamily: 'monospace',
        backgroundColor: Colors.grey[100],
        color: const Color(0xFF660F15),
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      
      // テーブルスタイル
      tableHead: TextStyle(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
        fontSize: 16,
      ),
      tableBody: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
      tableBorder: TableBorder.all(
        color: Colors.grey[300]!,
        width: 1,
      ),
      tableColumnWidth: const FlexColumnWidth(),
      
      // その他のスタイル
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      
      // 強調・斜体
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void _handleLinkTap(String? href) async {
    if (href != null) {
      try {
        final uri = Uri.parse(href);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('リンクを開けませんでした: $href, エラー: $e');
      }
    }
  }

  Widget _buildImage(Uri uri, String? title, String? altText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: uri.toString(),
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '画像を読み込めませんでした',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (altText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          altText,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // キャプション表示
          if (title != null && title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// シンプルなMarkdownビューアー（最小限のスタイリング）
class SimpleMarkdownViewer extends StatelessWidget {
  final String markdownContent;

  const SimpleMarkdownViewer({
    Key? key,
    required this.markdownContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdownContent.isEmpty ? '' : markdownContent,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Colors.black87,
        ),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.4,
        ),
        h2: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.4,
        ),
        h3: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.4,
        ),
      ),
      selectable: true,
    );
  }
}