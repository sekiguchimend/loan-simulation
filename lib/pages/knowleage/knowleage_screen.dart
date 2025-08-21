import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KnowleageScreen extends HookConsumerWidget {
  const KnowleageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('不動産の知識'),
        centerTitle: true,
      ),
      body: Center(
        child: Icon(
          Icons.menu_book,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}