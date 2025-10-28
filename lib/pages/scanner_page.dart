import 'package:flutter/material.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Сканер'),
      ),
      body: const Center(
        child: Text(
          'Экран сканера (заглушка)',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      bottomNavigationBar: NavPanel(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/recipes');
          } else if (index == 2) {
            // already on scanner
          }
        },
      ),
    );
  }
}