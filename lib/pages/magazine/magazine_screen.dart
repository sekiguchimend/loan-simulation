import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MagazineScreen extends HookConsumerWidget {
  const MagazineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('大吉マガジン'),
        centerTitle: true,
      ),
      body: Center(
        child: Icon(
          Icons.library_books,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}