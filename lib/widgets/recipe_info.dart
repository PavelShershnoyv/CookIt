import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  final String amount;
  final IconData icon;

  const Ingredient({
    required this.name,
    required this.amount,
    this.icon = Icons.rice_bowl,
  });
}

class RecipeInfo extends StatelessWidget {
  final String title;
  final String nutrition;
  final String imageAsset;
  final bool favorite;
  final List<Ingredient> ingredients;
  final VoidCallback? onFavoriteTap;

  const RecipeInfo({
    super.key,
    required this.title,
    required this.nutrition,
    required this.imageAsset,
    required this.ingredients,
    this.favorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset(
                imageAsset,
                height: 220,
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
                    color: favorite ? gradientStart : const Color(0x332D2D2D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: favorite ? Colors.black : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nutrition,
                    style: const TextStyle(
                      color: gradientStart,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x1F000000),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(ingredient.icon, color: Colors.white, size: 18),
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