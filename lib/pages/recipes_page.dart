import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/design/images.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

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
              _Filters(),
              const SizedBox(height: 16),
              // Промо-карточка рецепта (как в макете)
              const _FeaturedRecipeCard(),
              const SizedBox(height: 24),
              // Subtitle (перемещено ниже промо-карточки)
              const Text(
                '10 доступных рецептов',
                style: TextStyle(
                  color: Color(0xFFBBBCBC),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Recipe grid 2 x 3
              _RecipeGrid(),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _FilterChip(label: 'Все', selected: true),
        _FilterChip(label: 'Завтрак'),
        _FilterChip(label: 'Обед'),
        _FilterChip(label: 'Ужин'),
        _FilterChip(label: 'Десерт'),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, this.selected = false});

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: decoration,
      child: Text(label, style: TextStyle(color: textColor, fontSize: 18)),
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
                  'Паста фузилли',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '200 ккал на 100 г',
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
          // Right side: image placeholder (using dinner icon)
          Container(
            width: 140,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0x332D2D2D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Image.asset(
                dinnerImg,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _RecipeRow(
          left: RecipeCard(
            title: 'Греческий салат',
            time: '15 мин',
            ingredientsOwned: 8,
            ingredientsTotal: 10,
            favorite: true,
          ),
          right: RecipeCard(
            title: 'Жаренная курица',
            time: '25 мин',
            ingredientsOwned: 3,
            ingredientsTotal: 4,
          ),
        ),
        SizedBox(height: 16),
        _RecipeRow(
          left: RecipeCard(
            title: 'Паста фузилли',
            time: '20 мин',
            ingredientsOwned: 6,
            ingredientsTotal: 9,
          ),
          right: RecipeCard(
            title: 'Греческий салат',
            time: '15 мин',
            ingredientsOwned: 8,
            ingredientsTotal: 10,
          ),
        ),
        SizedBox(height: 16),
        _RecipeRow(
          left: RecipeCard(
            title: 'Жаренная курица',
            time: '25 мин',
            ingredientsOwned: 2,
            ingredientsTotal: 5,
          ),
          right: RecipeCard(
            title: 'Греческий салат',
            time: '15 мин',
            ingredientsOwned: 8,
            ingredientsTotal: 10,
          ),
        ),
      ],
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
