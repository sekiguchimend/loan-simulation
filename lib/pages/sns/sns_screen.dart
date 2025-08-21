import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SnsScreen extends HookConsumerWidget {
  const SnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS'),
        centerTitle: true,
      ),
      body: Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}