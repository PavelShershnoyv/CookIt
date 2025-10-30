import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:cookit/widgets/recipe_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeInfoPage extends StatefulWidget {
  final String title;
  final String nutrition;
  final String imageAsset;
  final bool favorite;
  final List<Ingredient> ingredients;

  const RecipeInfoPage({
    super.key,
    required this.title,
    required this.nutrition,
    required this.imageAsset,
    required this.ingredients,
    this.favorite = false,
  });

  factory RecipeInfoPage.fromState(GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final title = extra?['title'] as String? ?? 'Рецепт';
    final nutrition = extra?['nutrition'] as String? ?? '200 ккал на 100 г';
    final imageAsset = extra?['imageAsset'] as String? ?? 'assets/images/mock.jpg';
    final favorite = extra?['favorite'] as bool? ?? false;
    final ingredients = (extra?['ingredients'] as List<Ingredient>?) ??
        const [
          Ingredient(name: 'Куриное филе', amount: '200 г', icon: Icons.set_meal),
          Ingredient(name: 'Оливковое масло', amount: '1 ст.л.', icon: Icons.invert_colors),
          Ingredient(name: 'Соль', amount: 'по вкусу', icon: Icons.spa),
        ];
    return RecipeInfoPage(
      title: title,
      nutrition: nutrition,
      imageAsset: imageAsset,
      ingredients: ingredients,
      favorite: favorite,
    );
  }

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    // По требованию: на экране информации сердце неактивно изначально
    isFavorite = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 120),
          child: RecipeInfo(
            title: widget.title,
            nutrition: widget.nutrition,
            imageAsset: widget.imageAsset,
            ingredients: widget.ingredients,
            favorite: isFavorite,
            onFavoriteTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            onStartCooking: () {
              final defaultSteps = <String>[
                'Подготовьте продукты и рабочее место.',
                'Нарежьте ингредиенты согласно рецепту.',
                'Разогрейте сковороду/духовку и начните готовить.',
                'Добавьте специи, перемешайте и доведите до нужной степени.',
                'Проверьте готовность, снимите с огня.',
                'Подавайте блюдо, украсьте по вкусу.',
              ];
              context.push('/recipe/steps', extra: {
                'title': widget.title,
                'nutrition': widget.nutrition,
                'imageAsset': widget.imageAsset,
                'steps': defaultSteps,
              });
            },
          ),
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
      ),
    );
  }
}