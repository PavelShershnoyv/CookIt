import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CookingStepsPage extends StatelessWidget {
  final String title;
  final String nutrition;
  final String imageAsset;
  final List<String> steps;

  const CookingStepsPage({
    super.key,
    required this.title,
    required this.nutrition,
    required this.imageAsset,
    required this.steps,
  });

  factory CookingStepsPage.fromState(GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final title = extra?['title'] as String? ?? 'Рецепт';
    final nutrition = extra?['nutrition'] as String? ?? '200 ккал на 100 г';
    final imageAsset = extra?['imageAsset'] as String? ?? 'assets/images/mock.jpg';
    final steps = (extra?['steps'] as List<String>?) ?? const [
      'Промыть и подготовить продукты.',
      'Нарезать основные ингредиенты.',
      'Разогреть масло и начать жарку.',
      'Добавить специи и перемешать.',
      'Доведите до готовности на среднем огне.',
      'Подавайте горячим, украсьте по вкусу.',
    ];
    return CookingStepsPage(
      title: title,
      nutrition: nutrition,
      imageAsset: imageAsset,
      steps: steps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double heroHeight = size.height * 0.35;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image + overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(radius30),
                      topRight: Radius.circular(radius30),
                    ),
                    child: Image.asset(
                      imageAsset,
                      height: heroHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0xCC121212),
                          ],
                          stops: [0.32, 0.69],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nutrition,
                          style: const TextStyle(
                            color: gradientStart,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Steps title (left aligned per mockup)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Пошаговый рецепт',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Steps list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < steps.length; i++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFFB3F800),
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'шаг',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F2F2F),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          steps[i],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color(0xFFB3F800),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),

              // Bottom actions (Back / Finish)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF292929),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Назад',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Завершение — возвращаемся на экран рецептов
                          if (context.canPop()) {
                            Navigator.of(context).pop();
                          }
                          context.go('/recipes');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: gradientStart,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Завершить',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}