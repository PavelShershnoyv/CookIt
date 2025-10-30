import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/design/images.dart';
import 'package:cookit/widgets/recipe_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookit/data/recipe.dart';
import 'package:cookit/data/fridge_store.dart';

class RecipesPage extends StatefulWidget {
  final String? initialSelected;
  const RecipesPage({super.key, this.initialSelected});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String _selected = 'Все';
  bool _loading = true;
  String? _error;
  List<Recipe> _recipes = const [];

  @override
  void initState() {
    super.initState();
    // Инициализируем выбранный фильтр из параметра навигации, если он валиден
    const allowed = ['Все', 'Завтрак', 'Обед', 'Ужин', 'Десерт'];
    final init = widget.initialSelected;
    if (init != null && allowed.contains(init)) {
      _selected = init;
    }
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final uri = Uri.parse('http://121.127.37.220:8000/recepts?limit=200');
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        final recipes = data
            .whereType<Map<String, dynamic>>()
            .map((j) => Recipe.fromJson(j))
            .toList();
        setState(() {
          _recipes = recipes;
          _loading = false;
        });
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

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
              const SizedBox(height: 24),
              // Recipe grid
              if (_loading)
                const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB3F800)))
              else if (_error != null)
                Text(
                  'Ошибка загрузки рецептов: \n$_error',
                  style: const TextStyle(color: Colors.redAccent),
                )
              else
                ValueListenableBuilder<List<FridgeItem>>(
                  valueListenable: FridgeStore.instance.itemsListenable,
                  builder: (context, fridgeItems, _) {
                    final items = _recipes.map((r) {
                      final ingredients = _parseIngredients(r.sastav);
                      final owned = _countOwned(ingredients, fridgeItems);
                      final total = ingredients.length;
                      return _RecipeItem(
                        title: r.name,
                        time: '—',
                        owned: owned,
                        total: total,
                        favorite: false,
                        imageAsset: 'assets/images/mock.jpg',
                        category: _mapCategory(r.category),
                        recipe: r,
                      );
                    }).toList();

                    final availableCount = items
                        .where((e) => e.total > 0 && e.owned >= e.total)
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selected == 'Все')
                          _AvailableCount(count: availableCount),
                        if (_selected == 'Все') const SizedBox(height: 24),
                        _RecipeGrid(
                          selectedCategory: _selected,
                          onlyAvailable: _selected == 'Все',
                          items: items,
                        ),
                      ],
                    );
                  },
                ),
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
  final List<_RecipeItem> items;
  const _RecipeGrid(
      {required this.selectedCategory,
      required this.onlyAvailable,
      required this.items});

  @override
  Widget build(BuildContext context) {
    final all = items;

    final base = selectedCategory == 'Все'
        ? all
        : all.where((e) => e.category == selectedCategory).toList();
    final filtered = onlyAvailable
        ? base.where((e) => e.total > 0 && e.owned >= e.total).toList()
        : base;

    // Рисуем по двум колонкам c равными отступами между рядами
    final List<Widget> children = [];
    for (int i = 0; i < filtered.length; i += 2) {
      final left = filtered[i];
      final right = (i + 1 < filtered.length) ? filtered[i + 1] : null;
      children.add(
        _RecipeRow(
          left: _buildCard(context, left),
          right: right != null
              ? _buildCard(context, right)
              : const SizedBox.shrink(),
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
    final ingredients = _parseIngredients(item.recipe.sastav);
    final steps = _parseSteps(item.recipe.instruction);
    return {
      'title': item.title,
      'nutrition': '—',
      'imageAsset': item.imageAsset ?? 'assets/images/mock.jpg',
      'favorite': item.favorite,
      'ingredients': ingredients,
      'steps': steps,
    };
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
  final Recipe recipe;
  _RecipeItem({
    required this.title,
    required this.time,
    required this.owned,
    required this.total,
    this.favorite = false,
    this.imageAsset,
    required this.category,
    required this.recipe,
  });
}

class _AvailableCount extends StatelessWidget {
  final int count;
  const _AvailableCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count доступных рецептов',
      style: const TextStyle(
        color: Color(0xFFBBBCBC),
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

String _mapCategory(int? c) {
  switch (c) {
    case 2:
      return 'Завтрак';
    case 3:
      return 'Ужин';
    case 1:
    default:
      return 'Обед';
  }
}

List<Ingredient> _parseIngredients(String raw) {
  var s = raw.replaceAll('\r', '');
  s = s.replaceAll('Ингредиенты:', '');
  // Убираем текст вида "На X порций:"
  s = s.replaceAll(RegExp(r'На\s+\d+\s+порции?:'), '');
  // Парсим строго по запятой
  final parts = s.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);

  // Часто встречающиеся единицы измерения
  final unitCandidates = <String>{
    'гр',
    'кг',
    'мг',
    'мл',
    'л',
    'шт',
    'ст.л.',
    'ч.л.',
    'ст. л.',
    'ч. л.',
    'стакан',
    'чашка',
    'пучок',
    'щепотка',
    'долька',
    'головка',
    'пакет',
    'пакетик',
    'ломтик',
    'кусок',
    'капля',
    'по вкусу',
  };

  final List<Ingredient> res = [];
  for (final original in parts) {
    var p = original.trim();
    if (p.isEmpty) continue;

    // Нормализуем разделители
    p = p.replaceAll(RegExp(r'[–—]'), ' '); // длинные дефисы → пробел
    p = p.replaceAll(':', ' ');

    // Ищем количество (первая числовая группа)
    final qtyMatch = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(p);
    final qty = qtyMatch != null ? qtyMatch.group(1)!.trim() : '';

    // Ищем единицу измерения по списку кандидатов (кейсы и точки учитываем)
    String unit = '';
    final lower = p.toLowerCase();
    for (final u in unitCandidates) {
      if (lower.contains(u)) {
        unit = u;
        break;
      }
    }

    // Формируем amount по найденным значениям (сохраняем и количеcтво, и единицы)
    String amount = '';
    if (unit.isNotEmpty && qty.isNotEmpty) {
      amount = '$qty $unit';
    } else if (unit.isNotEmpty) {
      amount = unit;
    } else if (qty.isNotEmpty) {
      amount = qty;
    }

    // Выделяем название: выкидываем qty и unit из строки
    var name = p;
    if (qty.isNotEmpty) {
      name = name.replaceFirst(qty, '');
    }
    if (unit.isNotEmpty) {
      name = name.replaceFirst(
          RegExp(RegExp.escape(unit), caseSensitive: false), '');
    }
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Если имя пустое — оставляем оригинал
    if (name.isEmpty) name = original.trim();

    res.add(Ingredient(name: _capitalize(name), amount: amount));
  }

  if (res.isEmpty) {
    res.add(const Ingredient(name: 'Ингредиенты не указаны', amount: ''));
  }
  return res;
}

List<String> _parseSteps(String raw) {
  var s = raw.replaceAll('\r', '');
  s = s.replaceAll('Инструкции:', '');
  final lines =
      s.split('\\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  final steps = <String>[];
  for (final l in lines) {
    var t = l;
    t = t.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
    if (t.isNotEmpty) steps.add(_capitalize(t));
  }
  if (steps.isEmpty) {
    steps.add('Инструкция не указана');
  }
  return steps;
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
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

int _countOwned(List<Ingredient> ingredients, List<FridgeItem> fridgeItems) {
  int owned = 0;
  for (final ing in ingredients) {
    final has = fridgeItems.any((f) => _nameMatches(ing.name, f.title));
    if (has) owned++;
  }
  return owned;
}

String _normalize(String s) {
  var t = s.toLowerCase();
  t = t.replaceAll(RegExp(r'[^a-zA-Zа-яА-Я0-9\s]'), '');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t;
}

bool _nameMatches(String a, String b) {
  final na = _normalize(a);
  final nb = _normalize(b);
  return na == nb || na.contains(nb) || nb.contains(na);
}
