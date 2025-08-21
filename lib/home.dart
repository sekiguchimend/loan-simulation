import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/loansimulator/loansimulator_screen.dart';
import 'pages/knowleage/knowleage_screen.dart';
import 'pages/magazine/magazine_screen.dart';
import 'pages/sns/sns_screen.dart';
import 'pages/consult/consult_screen.dart';

// Supabaseクライアントのグローバルアクセス
final supabase = Supabase.instance.client;

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    final List<Widget> pages = [
      LoanSimulatorScreen(),
      KnowleageScreen(),
      MagazineScreen(),
      SnsScreen(),
      ConsultScreen(),
    ];

    return Scaffold(
      body: pages[selectedIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        onTap: (index) {
          selectedIndex.value = index;
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: '電卓',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '不動産の知識',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '大吉マガジン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'SNS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ご相談',
          ),
        ],
      ),
    );
  }
}