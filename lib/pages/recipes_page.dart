import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/design/images.dart';
import 'package:cookit/widgets/recipe_info.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String _selected = 'Все';

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
              // Title
              const Text(
                'Рецепты',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              // Filters row (перемещено под заголовок)
              _Filters(
                selected: _selected,
                onSelected: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 16),
              // Промо-карточка рецепта только в разделе "Все"
              if (_selected == 'Все') const _FeaturedRecipeCard(),
              const SizedBox(height: 24),
              // Subtitle (перемещено ниже промо-карточки)
              if (_selected == 'Все') _AvailableCount(selected: _selected),
              const SizedBox(height: 24),
              // Recipe grid 2 x 3
              _RecipeGrid(selectedCategory: _selected, onlyAvailable: _selected == 'Все'),
              const SizedBox(height: 24),
              // Info chips
            ],
          ),
        ),
      ),
      // Bottom navigation (styled pill)
      bottomNavigationBar: NavPanel(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/fridge');
          } else if (index == 1) {
            // already on recipes
          } else if (index == 2) {
            context.go('/scanner');
          }
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _Filters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label) => _FilterChip(
          label: label,
          selected: selected == label,
          onTap: () => onSelected(label),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Все'),
          const SizedBox(width: 12),
          chip('Завтрак'),
          const SizedBox(width: 12),
          chip('Обед'),
          const SizedBox(width: 12),
          chip('Ужин'),
          const SizedBox(width: 12),
          chip('Десерт'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _FilterChip({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final decoration = selected
        ? BoxDecoration(
            color: const Color(0xFFB3F800),
            borderRadius: BorderRadius.circular(100),
          )
        : BoxDecoration(
            color: const Color(0x332D2D2D),
            borderRadius: BorderRadius.circular(100),
          );
    final textColor = selected ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: decoration,
        child: Text(label, style: TextStyle(color: textColor, fontSize: 18)),
      ),
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1F000000),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left side: text and button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Греческий салат',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '120 ккал на 100 г',
                  style: TextStyle(
                    color: Color(0xFFBBBCBC),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Show button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F800),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Показать',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
  // Right side: image
  Container(
    width: 140,
    height: 120,
    decoration: BoxDecoration(
      color: const Color(0x332D2D2D),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Center(
      child: Image.asset(
        'assets/images/mock.jpg',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    ),
  ),
        ],
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  final String selectedCategory;
  final bool onlyAvailable;
  const _RecipeGrid({required this.selectedCategory, required this.onlyAvailable});

  @override
  Widget build(BuildContext context) {
  final all = <_RecipeItem>[
    _RecipeItem(
      title: 'Греческий салат',
      time: '15 мин',
      owned: 10,
      total: 10,
      favorite: true,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Обед',
    ),
    _RecipeItem(
      title: 'Жаренная курица',
      time: '25 мин',
      owned: 4,
      total: 4,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Ужин',
    ),
    _RecipeItem(
      title: 'Паста фузилли',
      time: '20 мин',
      owned: 6,
      total: 9,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Обед',
    ),
    _RecipeItem(
      title: 'Греческий салат',
      time: '15 мин',
      owned: 8,
      total: 10,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Обед',
    ),
    _RecipeItem(
      title: 'Жаренная курица',
      time: '25 мин',
      owned: 2,
      total: 5,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Ужин',
    ),
    _RecipeItem(
      title: 'Греческий салат',
      time: '15 мин',
      owned: 8,
      total: 10,
      imageAsset: 'assets/images/mock.jpg',
      category: 'Обед',
    ),
  ];

    final base = selectedCategory == 'Все'
        ? all
        : all.where((e) => e.category == selectedCategory).toList();
    final filtered = onlyAvailable
        ? base.where((e) => e.owned >= e.total).toList()
        : base;

    // Рисуем по двум колонкам c равными отступами между рядами
    final List<Widget> children = [];
    for (int i = 0; i < filtered.length; i += 2) {
      final left = filtered[i];
      final right = (i + 1 < filtered.length) ? filtered[i + 1] : null;
      children.add(
        _RecipeRow(
          left: _buildCard(context, left),
          right:
              right != null ? _buildCard(context, right) : const SizedBox.shrink(),
        ),
      );
      if (i + 2 < filtered.length) {
        children.add(const SizedBox(height: 16));
      }
    }

    return Column(children: children);
  }

  Widget _buildCard(BuildContext context, _RecipeItem item) {
    return RecipeCard(
      title: item.title,
      time: item.time,
      ingredientsOwned: item.owned,
      ingredientsTotal: item.total,
      favorite: item.favorite,
      imageAsset: item.imageAsset,
      onTap: () => context.push('/recipe', extra: _extrasFor(item)),
    );
  }

  Map<String, dynamic> _extrasFor(_RecipeItem item) {
    switch (item.title) {
      case 'Греческий салат':
        return {
          'title': item.title,
          'nutrition': '120 ккал на 100 г',
          'imageAsset': 'assets/images/mock.jpg',
          'favorite': item.favorite,
          'ingredients': const [
            Ingredient(name: 'Помидоры', amount: '2 шт', icon: Icons.local_florist),
            Ingredient(name: 'Огурец', amount: '1 шт', icon: Icons.eco),
            Ingredient(name: 'Сыр фета', amount: '150 г', icon: Icons.icecream),
            Ingredient(name: 'Оливки', amount: '50 г', icon: Icons.circle),
          ],
        };
      case 'Жаренная курица':
        return {
          'title': item.title,
          'nutrition': '165 ккал на 100 г',
          'imageAsset': 'assets/images/mock.jpg',
          'favorite': item.favorite,
          'ingredients': const [
            Ingredient(name: 'Куриное филе', amount: '300 г', icon: Icons.set_meal),
            Ingredient(name: 'Масло', amount: '1 ст.л.', icon: Icons.invert_colors),
            Ingredient(name: 'Чеснок', amount: '2 зубчика', icon: Icons.spa),
          ],
        };
      case 'Паста фузилли':
        return {
          'title': item.title,
          'nutrition': '200 ккал на 100 г',
          'imageAsset': 'assets/images/mock.jpg',
          'favorite': item.favorite,
          'ingredients': const [
            Ingredient(name: 'Паста фузилли', amount: '200 г', icon: Icons.ramen_dining),
            Ingredient(name: 'Сливки', amount: '100 мл', icon: Icons.local_drink),
            Ingredient(name: 'Сыр', amount: '50 г', icon: Icons.icecream),
          ],
        };
      default:
        return {
          'title': item.title,
          'nutrition': '100 ккал на 100 г',
          'imageAsset': 'assets/images/mock.jpg',
          'favorite': item.favorite,
          'ingredients': const [],
        };
    }
  }
}

class _RecipeItem {
  final String title;
  final String time;
  final int owned;
  final int total;
  final bool favorite;
  final String? imageAsset;
  final String category;
  _RecipeItem({
    required this.title,
    required this.time,
    required this.owned,
    required this.total,
    this.favorite = false,
    this.imageAsset,
    required this.category,
  });
}

class _AvailableCount extends StatelessWidget {
  final String selected;
  const _AvailableCount({required this.selected});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {
      'Все': 2,
    };
    final value = counts[selected] ?? 0;
    return Text(
      '$value доступных рецептов',
      style: const TextStyle(
        color: Color(0xFFBBBCBC),
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _RecipeRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _RecipeRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
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
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
