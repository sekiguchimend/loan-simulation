import 'package:flutter/material.dart';
import '../magazine_screen.dart'; // BlogMagazineモデルをインポート

class MagazineCardWidget extends StatelessWidget {
  final BlogMagazine magazine;
  final VoidCallback onTap;

  const MagazineCardWidget({
    super.key,
    required this.magazine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 16:9の縦横比で高さを計算（横のパディング32pxを考慮）
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // 左右のパディング16px * 2
    final cardHeight = cardWidth * 9 / 16; // 16:9の比率
    
    return Container(
      width: double.infinity,
      height: cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: magazine.thumbnail != null && magazine.thumbnail!.isNotEmpty
              ? Image.network(
                  magazine.thumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: cardHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return MagazinePlaceholder(height: cardHeight);
                  },
                )
              : MagazinePlaceholder(height: cardHeight),
        ),
      ),
    );
  }
}

class MagazinePlaceholder extends StatelessWidget {
  final double height;

  const MagazinePlaceholder({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'マガジン画像',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MagazineCardSkeleton extends StatelessWidget {
  const MagazineCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 9 / 16; // 16:9の比率
        
        return Container(
          width: double.infinity,
          height: cardHeight,
          color: Colors.grey[300],
        );
      },
    );
  }
}

class NoMagazineCard extends StatelessWidget {
  const NoMagazineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 9 / 16; // 16:9の比率
        
        return Container(
          width: double.infinity,
          height: cardHeight,
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'マガジンはまだ準備中です',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}