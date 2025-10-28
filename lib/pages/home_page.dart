import 'package:cookit/design/colors.dart';
import 'package:cookit/design/images.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'С возвращением, Юлия',
                style: const TextStyle(
                  color: subtitleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              // Title
              const SizedBox(height: 16),
              // Promo gradient card with scan action
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientStart, gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Что приготовить  сегодня?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Сканируй продукты - получи идеи',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x69000000),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon(scannerImage, color: Colors.white, size: 30),
                            scannerImage,
                            SizedBox(width: 10),
                            Text(
                              'Сканировать',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Categories row
              _Categories(),
              const SizedBox(height: 24),
              // For you section header with filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Для Вас',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                  ),
                  _FilterAll(),
                ],
              ),
              const SizedBox(height: 16),
              // Горизонтальный список рецептов
              const SizedBox(
                height: 220,
                child: _HorizontalRecipesList(),
              ),
              const SizedBox(height: 24),
              // Info chips row
              Row(
                children: const [
                  _InfoChip(text: 'У вас 9/10'),
                  SizedBox(width: 8),
                  _InfoChip(text: 'У вас 3/4'),
                ],
              ),
              const SizedBox(height: 24),
              // Bottom icons row (placeholder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _CircleIcon(icon: Icons.kitchen),
                  _CircleIcon(icon: Icons.receipt_long),
                  _CircleIcon(icon: Icons.favorite),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavPanel(
        selectedIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/recipes');
          } else if (index == 2) {
            context.go('/scanner');
          }
        },
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: Colors.white, fontSize: 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Category(icon: Icons.free_breakfast, label: 'Завтрак'),
        _Category(icon: Icons.ramen_dining, label: 'Обед'),
        _Category(icon: Icons.dinner_dining, label: 'Ужин'),
        _Category(icon: Icons.cake, label: 'Десерт'),
      ],
    );
  }
}

class _Category extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Category({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0x332D2D2D),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _FilterAll extends StatelessWidget {
  const _FilterAll();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x19000000),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Все ', style: TextStyle(color: Colors.white, fontSize: 16)),
          Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _HorizontalRecipesList extends StatelessWidget {
  const _HorizontalRecipesList();

  @override
  Widget build(BuildContext context) {
    // Демонстрационные данные: количество может меняться (например, 4–20)
    const items = [
      {
        'title': 'Греческий салат',
        'time': '15 мин',
        'color': Color(0xFF6E8B3D),
        'own': 8,
        'total': 10,
        'fav': true
      },
      {
        'title': 'Жаренная курица',
        'time': '25 мин',
        'color': Color(0xFF8B5E3D),
        'own': 3,
        'total': 4,
        'fav': false
      },
      {
        'title': 'Паста фузилли',
        'time': '20 мин',
        'color': Color(0xFF5E6A9A),
        'own': 6,
        'total': 9,
        'fav': false
      },
      {
        'title': 'Салат боул',
        'time': '18 мин',
        'color': Color(0xFF6E8B3D),
        'own': 7,
        'total': 11,
        'fav': false
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final right = index == items.length - 1 ? 0.0 : 12.0;
          return Padding(
            padding: EdgeInsets.only(right: right),
            child: SizedBox(
              width: 200,
              child: RecipeCard(
                title: item['title'] as String,
                time: item['time'] as String,
                ingredientsOwned: item['own'] as int,
                ingredientsTotal: item['total'] as int,
                favorite: item['fav'] as bool,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1214),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  const _CircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0x332D2D2D),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
