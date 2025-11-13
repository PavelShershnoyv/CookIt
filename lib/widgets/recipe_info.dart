import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  final String amount;
  final IconData icon;
  final String? iconAsset;

  const Ingredient({
    required this.name,
    required this.amount,
    this.icon = Icons.rice_bowl,
    this.iconAsset,
  });
}

class RecipeInfo extends StatelessWidget {
  final String title;
  final String nutrition;
  final String imageAsset;
  final String? imageUrl;
  final bool favorite;
  final List<Ingredient> ingredients;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onStartCooking;

  const RecipeInfo({
    super.key,
    required this.title,
    required this.nutrition,
    required this.imageAsset,
    this.imageUrl,
    required this.ingredients,
    this.favorite = false,
    this.onFavoriteTap,
    this.onStartCooking,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double heroHeight = screenSize.height * 0.35;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(radius30),
                topRight: Radius.circular(radius30),
              ),
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? Image.network(
                      imageUrl!,
                      height: heroHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imageAsset,
                      height: heroHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292E31),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      favorite
                          ? 'assets/images/heart_green.png'
                          : 'assets/images/heart.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nutrition,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: gradientStart,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onStartCooking,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3F800),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Начать готовить',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0x1F000000),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius30),
              bottomRight: Radius.circular(radius30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ингредиенты',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...ingredients.map((i) => _IngredientRow(ingredient: i)).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x332D2D2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x1F000000),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: ingredient.iconAsset != null
                  ? Image.asset(
                      ingredient.iconAsset!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    )
                  : Icon(ingredient.icon, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            ingredient.amount,
            style: const TextStyle(
              color: Color(0xFFDADADA),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}