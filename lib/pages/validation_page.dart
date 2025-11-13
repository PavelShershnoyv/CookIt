import 'package:flutter/material.dart';
import 'package:cookit/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/data/fridge_store.dart';
import 'package:cookit/design/ingredient_icons.dart';

class ValidationPage extends StatefulWidget {
  final Map<String, dynamic>? payload;
  const ValidationPage({super.key, this.payload});

  factory ValidationPage.fromState(GoRouterState state) {
    final extra = state.extra;
    final payload = extra is Map<String, dynamic> ? extra : null;
    return ValidationPage(payload: payload);
  }

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  late final List<_Item> _items;

  @override
  void initState() {
    super.initState();
    final detected = (widget.payload?['ingredients'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (widget.payload?['detected_ingredients'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [
          'яйцо',
          'молоко',
          'оливковое масло',
          'лимон',
          'яблоко',
        ];
    _items = detected
        .map((name) => _Item(
              _capitalize(name),
              IngredientIcons.fallbackIconForName(name),
              IngredientIcons.iconAssetForName(name),
            ))
        .toList();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Icon fallback handled via IngredientIcons.fallbackIconForName

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Фото холодильника с затемнением снизу
              SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/validation.png',
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Проверка',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Пожалуйста, подтвердите\nраспознанные продукты',
                      style: TextStyle(
                        color: Color(0xFFB3F800),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Список распознанных продуктов
                    for (int i = 0; i < _items.length; i++) ...[
                      _ValidationRow(
                        title: _items[i].name,
                        icon: _items[i].icon,
                        iconAsset: _items[i].iconAsset,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),

                    // Нижняя панель действий
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Отмена',
                            backgroundColor: const Color(0x1F000000),
                            textColor: Colors.white,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Продолжить',
                            backgroundColor: const Color(0xFFB3F800),
                            textColor: Colors.black,
                            onTap: () {
                              // Сохраняем подтверждённые продукты в хранилище холодильника
                              final itemsToAdd = _items
                                  .map((e) => FridgeItem(
                                        title: e.name,
                                        amount: '—',
                                        icon: e.icon,
                                        iconAsset: e.iconAsset,
                                      ))
                                  .toList();
                              FridgeStore.instance.addAll(itemsToAdd);
                              // И переходим на страницу рецептов
                              context.go('/recipes');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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

class _ValidationRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? iconAsset;
  

  const _ValidationRow({
    required this.title,
    required this.icon,
    this.iconAsset,
  });

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x332D2D2D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: iconAsset != null
                ? Image.asset(
                    iconAsset!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  )
                : Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Кнопки управления количеством продуктов в макете отсутствуют.

class _ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final String name;
  final IconData icon;
  final String? iconAsset;
  const _Item(this.name, this.icon, this.iconAsset);
}