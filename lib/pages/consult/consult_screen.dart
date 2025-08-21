import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConsultScreen extends HookConsumerWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ご相談'),
        centerTitle: true,
      ),
      body: Center(
        child: Icon(
          Icons.chat,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}