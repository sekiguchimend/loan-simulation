import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/loansimulator/loansimulator_screen.dart';
import 'pages/overview/overview_screen.dart';
import 'pages/knowleage/knowledge_screen.dart';
import 'pages/magazine/magazine_screen.dart';
import 'pages/consult/consult_screen.dart';

// Supabaseクライアントのグローバルアクセス
final supabase = Supabase.instance.client;

class HomePage extends HookConsumerWidget {
  final int? initialIndex;
  const HomePage({super.key, this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check for arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    final int? routeIndex = args is int ? args : null;

    final selectedIndex = useState(routeIndex ?? initialIndex ?? 0);

    // Update selectedIndex when initialIndex or routeIndex changes
    useEffect(() {
      final index = initialIndex; // Create local variable to avoid promotion issue
      if (routeIndex != null) {
        selectedIndex.value = routeIndex;
      } else if (index != null) {
        selectedIndex.value = index;
      }
      return null;
    }, [routeIndex, initialIndex]);

    final List<Widget> pages = [
      LoanSimulatorScreen(),
      OverviewScreen(),
      KnowleageScreen(),
      MagazineScreen(),
      ConsultScreen(),
    ];

    return Scaffold(
      body: pages[selectedIndex.value],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: selectedIndex.value,
        onTap: (index) {
          selectedIndex.value = index;
        },
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.calculate, 'label': '電卓'},
      {'icon': Icons.business, 'label': '概要'},
      {'icon': Icons.menu_book, 'label': '不動産の知識'},
      {'icon': Icons.library_books, 'label': '大吉マガジン'},
      {'icon': Icons.chat, 'label': 'ご相談'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = index == selectedIndex;
              final item = items[index];

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? Color(0xFFD30B17)
                            : Colors.grey,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Color(0xFFD30B17)
                              : Colors.grey,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}