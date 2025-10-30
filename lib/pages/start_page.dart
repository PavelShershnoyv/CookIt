import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:cookit/design/images.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:cookit/widgets/recipe_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        body: Padding(
          padding: const EdgeInsets.only(
              top: padding30, left: padding30, right: padding30),
          child: SafeArea(
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Аватар пользователя
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0x332D2D2D),
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                        ),
                        // Иконка избранного в круглой тёмной кнопке
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF292E31),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/heart.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: height16),
                    const Text(
                      "С возвращением, Юлия",
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 24,
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
                            GestureDetector(
                              onTap: () => context.go('/scanner'),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )
                                  ],
                                ),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
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
        ),
        bottomNavigationBar: NavPanel(
          selectedIndex: -1,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final tab = Uri.encodeComponent(label);
        context.go('/recipes?tab=$tab');
      },
      child: Column(
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
      ),
    );
  }
}

class _HorizontalRecipesList extends StatelessWidget {
  const _HorizontalRecipesList();

  @override
  Widget build(BuildContext context) {
    const items = [
      {
        'img': 'assets/images/salat.png',
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
                imageAsset: 'assets/images/mock.jpg',
                onTap: () {
                  final title = item['title'] as String;
                  final fav = item['fav'] as bool;
                  final extras = {
                    'title': title,
                    'nutrition': _nutritionFor(title),
                    'imageAsset': 'assets/images/mock.jpg',
                    'favorite': fav,
                    'ingredients': _ingredientsFor(title),
                  };
                  context.push('/recipe', extra: extras);
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  static String _nutritionFor(String title) {
    switch (title) {
      case 'Греческий салат':
        return '120 ккал на 100 г';
      case 'Жаренная курица':
        return '165 ккал на 100 г';
      case 'Паста фузилли':
        return '200 ккал на 100 г';
      case 'Салат боул':
        return '180 ккал на 100 г';
      default:
        return '200 ккал на 100 г';
    }
  }

  static List<Ingredient> _ingredientsFor(String title) {
    switch (title) {
      case 'Греческий салат':
        return const [
          Ingredient(name: 'Помидоры', amount: '2 шт', icon: Icons.local_florist),
          Ingredient(name: 'Огурец', amount: '1 шт', icon: Icons.eco),
          Ingredient(name: 'Сыр фета', amount: '150 г', icon: Icons.icecream),
          Ingredient(name: 'Оливки', amount: '50 г', icon: Icons.circle),
        ];
      case 'Жаренная курица':
        return const [
          Ingredient(name: 'Куриное филе', amount: '300 г', icon: Icons.set_meal),
          Ingredient(name: 'Масло', amount: '1 ст.л.', icon: Icons.invert_colors),
          Ingredient(name: 'Чеснок', amount: '2 зубчика', icon: Icons.spa),
        ];
      case 'Паста фузилли':
        return const [
          Ingredient(name: 'Паста фузилли', amount: '200 г', icon: Icons.ramen_dining),
          Ingredient(name: 'Сливки', amount: '100 мл', icon: Icons.local_drink),
          Ingredient(name: 'Сыр', amount: '50 г', icon: Icons.icecream),
        ];
      case 'Салат боул':
        return const [
          Ingredient(name: 'Киноа', amount: '100 г', icon: Icons.grass),
          Ingredient(name: 'Авокадо', amount: '1 шт', icon: Icons.spa),
          Ingredient(name: 'Огурец', amount: '1 шт', icon: Icons.eco),
        ];
      default:
        return const [
          Ingredient(name: 'Соль', amount: 'по вкусу'),
          Ingredient(name: 'Перец', amount: 'по вкусу'),
        ];
    }
  }
}
