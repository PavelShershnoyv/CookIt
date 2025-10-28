import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:cookit/design/images.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        body: Padding(
          padding: const EdgeInsets.only(left: padding30, right: padding30),
          child: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [Text("Icon Profile")],
              ),
              const SizedBox(height: height16),
              const Text(
                "С возвращением, Юлия",
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: height16),
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
                      const Text(
                        'Что приготовить  сегодня?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        'Сканируй продукты - получи идеи',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: height12),
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
                            Image.asset(scanImg),
                            const SizedBox(width: 10),
                            const Text(
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
              const SizedBox(height: height16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Category(icon: breakfastImg, label: 'Завтрак'),
                  _Category(icon: lunchImg, label: 'Обед'),
                  _Category(icon: dinnerImg, label: 'Ужин'),
                  _Category(icon: dessertImg, label: 'Десерт'),
                ],
              ),
              const SizedBox(height: height30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Для Вас',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Все ',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      Image.asset(arrowRightImg),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: height16),
              _HorizontalRecipesList()
            ],
          )),
        ),
        bottomNavigationBar: NavPanel(
          selectedIndex: 1,
          onTap: (index) {
            if (index == 0) {
              context.go('/fridge');
            } else if (index == 1) {
              context.go('/recipes');
            } else if (index == 2) {
              context.go('/scanner');
            }
          },
        ));
  }
}

class _Category extends StatelessWidget {
  final String icon;
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
          child: Image.asset(icon),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: textPrimary)),
      ],
    );
  }
}

class _HorizontalRecipesList extends StatelessWidget {
  const _HorizontalRecipesList();

  @override
  Widget build(BuildContext context) {
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
