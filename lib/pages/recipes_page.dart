import 'package:cookit/design/colors.dart';
import 'package:cookit/design/images.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';

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
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                '10 доступных рецептов',
                style: TextStyle(
                  color: Color(0xFFBBBCBC),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Filters row
              _Filters(),
              const SizedBox(height: 24),
              // Recipe grid 2 x 3
              _RecipeGrid(),
              const SizedBox(height: 24),
              // Info chips
              Row(
                children: const [
                  _InfoChip(text: 'У вас 8/10'),
                  SizedBox(width: 8),
                  _InfoChip(text: 'У вас 3/4'),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Bottom navigation (styled pill)
      bottomNavigationBar: const _BottomNav(),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x1A000000),
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(icon: fridgeImage, label: 'Холодильник'),
            _NavItem(icon: recipesImage, label: 'Рецепты', selected: true),
            _NavItem(icon: scannerImage, label: 'Сканер'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  const _NavItem(
      {required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 28, height: 28, child: icon),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFBBBCBC),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
