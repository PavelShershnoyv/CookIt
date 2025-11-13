import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:cookit/widgets/recipe_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeInfoPage extends StatefulWidget {
  final int? id;
  final String title;
  final String nutrition;
  final String imageAsset;
  final String? imageUrl;
  final bool favorite;
  final List<Ingredient> ingredients;
  final List<String> steps;

  const RecipeInfoPage({
    super.key,
    this.id,
    required this.title,
    required this.nutrition,
    required this.imageAsset,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    this.favorite = false,
  });

  factory RecipeInfoPage.fromState(GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final id = (extra?['id'] as int?) ?? (extra?['id'] is String ? int.tryParse(extra?['id'] as String) : null);
    final title = extra?['title'] as String? ?? 'Рецепт';
    final nutrition = extra?['nutrition'] as String? ?? '200 ккал на 100 г';
    final imageAsset = extra?['imageAsset'] as String? ?? 'assets/images/mock.jpg';
    final imageUrl = extra?['imageUrl'] as String?;
    final favorite = extra?['favorite'] as bool? ?? false;
    final ingredients = (extra?['ingredients'] as List<Ingredient>?) ??
        const [
          Ingredient(name: 'Куриное филе', amount: '200 г', icon: Icons.set_meal),
          Ingredient(name: 'Оливковое масло', amount: '1 ст.л.', icon: Icons.invert_colors),
          Ingredient(name: 'Соль', amount: 'по вкусу', icon: Icons.spa),
        ];
    final steps = (extra?['steps'] as List<String>?) ?? const [
      'Подготовьте продукты и рабочее место.',
      'Нарежьте ингредиенты согласно рецепту.',
      'Разогрейте сковороду/духовку и начните готовить.',
      'Добавьте специи, перемешайте и доведите до нужной степени.',
      'Проверьте готовность, снимите с огня.',
      'Подавайте блюдо, украсьте по вкусу.',
    ];
    return RecipeInfoPage(
      id: id,
      title: title,
      nutrition: nutrition,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
      ingredients: ingredients,
      steps: steps,
      favorite: favorite,
    );
  }

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  late bool isFavorite;
  late String _title;
  late String _nutrition;
  late String _imageAsset;
  String? _imageUrl;
  List<Ingredient> _ingredients = const [];
  List<String> _steps = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // По требованию: на экране информации сердце неактивно изначально
    isFavorite = false;
    // Инициализируем из переданных значений
    _title = widget.title;
    _nutrition = widget.nutrition;
    _imageAsset = widget.imageAsset;
    _imageUrl = widget.imageUrl;
    _ingredients = widget.ingredients;
    _steps = widget.steps;

    // Если есть id — подтягиваем подробности
    if (widget.id != null) {
      _fetchRecipeDetails(widget.id!);
    }
  }

  Future<void> _fetchRecipeDetails(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('http://121.127.37.220:8000/recipes/$id');
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final obj = (decoded is Map<String, dynamic>)
            ? decoded
            : (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>)
                ? decoded.first as Map<String, dynamic>
                : <String, dynamic>{};

        final title = obj['title'] as String?;
        final poster = obj['poster'] as String?;
        final difficulty = obj['difficulty'] as String?; // e.g., 'Низкая'
        final cooktime = obj['cooktime'] as String?; // e.g., '15 минут'

        final nutritionText = _composeNutrition(difficulty, cooktime);

        final ingredients = _parseIngredients(obj);
        final steps = _parseInstructions(obj);

        setState(() {
          if (title != null && title.isNotEmpty) _title = title;
          _imageUrl = (poster is String && poster.isNotEmpty) ? poster : _imageUrl;
          _nutrition = nutritionText ?? _nutrition;
          _ingredients = ingredients.isNotEmpty ? ingredients : _ingredients;
          _steps = steps.isNotEmpty ? steps : _steps;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Ошибка загрузки: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Ошибка сети';
      });
    }
  }

  String? _composeNutrition(String? difficulty, String? cooktime) {
    if ((difficulty == null || difficulty.isEmpty) && (cooktime == null || cooktime.isEmpty)) {
      return null;
    }
    if (difficulty != null && difficulty.isNotEmpty && cooktime != null && cooktime.isNotEmpty) {
      return '$difficulty • $cooktime';
    }
    return difficulty?.isNotEmpty == true ? difficulty : cooktime;
  }

  List<Ingredient> _parseIngredients(Map<String, dynamic> obj) {
    final List<Ingredient> out = [];
    final groups = obj['recipe_ingredient_groups'];
    if (groups is List) {
      for (final g in groups) {
        if (g is Map && g['ingredients'] is List) {
          for (final ing in (g['ingredients'] as List)) {
            if (ing is Map) {
              final name = (ing['name'] as String?)?.trim();
              final value = (ing['value'] as String?)?.trim();
              final type = (ing['type'] as String?)?.trim();
              final amount = (ing['amount'] as String?)?.trim();
              if (name != null && name.isNotEmpty) {
                final qty = amount?.isNotEmpty == true
                    ? amount!
                    : ((value?.isNotEmpty == true && type?.isNotEmpty == true)
                        ? '${value!} ${type!}'
                        : (value ?? type ?? ''));
                out.add(Ingredient(
                  name: name,
                  amount: qty,
                  iconAsset: _iconAssetForName(name),
                ));
              }
            }
          }
        }
      }
    }
    return out;
  }

  String? _iconAssetForName(String name) {
    final s = name.toLowerCase();
    // 11 категорий и соответствующие ассеты из assets/images
    // мучное -> bread
    if (s.contains('мука') || s.contains('макарон') || s.contains('спагет') || s.contains('лапш') ||
        s.contains('тесто') || s.contains('пицц') || s.contains('хлеб') || s.contains('булк') || s.contains('батон') ||
        s.contains('лаваш') || s.contains('тортиль') || s.contains('дрожж') || s.contains('крахмал')) {
      return 'assets/images/bread.png';
    }
    // мясо -> meet (по имени файла, оставляю ваш вариант)
    if (s.contains('мяс') || s.contains('говядин') || s.contains('свинин') || s.contains('баранин') ||
        s.contains('куриц') || s.contains('индейк') || s.contains('утк') || s.contains('ветчин') || s.contains('колбас')) {
      return 'assets/images/meet.png';
    }
    // рыба -> fish
    if (s.contains('рыб') || s.contains('лосос') || s.contains('тунец') || s.contains('хек') || s.contains('сельд') ||
        s.contains('минтай') || s.contains('семг')) {
      return 'assets/images/fish.png';
    }
    // молочка -> milk
    if (s.contains('молок') || s.contains('кефир') || s.contains('йогурт') || s.contains('сливк') || s.contains('ряженк') ||
        s.contains('сметан') || s.contains('морожен')) {
      return 'assets/images/milk.png';
    }
    // яйца -> eggs
    if (s.contains('яйц') || s.contains('перепелиные')) {
      return 'assets/images/eggs.png';
    }
    // масло -> oil
    if (s.contains('масло') || s.contains('оливков') || s.contains('подсолнеч')) {
      return 'assets/images/oil.png';
    }
    // фрукты -> apple (включая ягоды)
    if (s.contains('яблок') || s.contains('банан') || s.contains('апельсин') || s.contains('лимон') ||
        s.contains('груш') || s.contains('персик') || s.contains('виноград') || s.contains('киви') ||
        s.contains('малина') || s.contains('ягод') || s.contains('клубник') || s.contains('черник') || s.contains('голубик') || s.contains('брусник') || s.contains('клюкв') || s.contains('ежевик') || s.contains('смородин')) {
      return 'assets/images/apple.png';
    }
    // овощи -> carrot
    if (s.contains('капуст') || s.contains('огур') || s.contains('лук') || s.contains('помидор') || s.contains('томат') ||
        s.contains('картоф') || s.contains('морков') || s.contains('перец') || s.contains('кабач') || s.contains('баклаж') ||
        s.contains('свекл') || s.contains('укроп') || s.contains('петруш') || s.contains('зелень')) {
      return 'assets/images/carrot.png';
    }
    // специи -> salt (включая соль, перец, сахар, разрыхлитель и прочие специи)
    if (s.contains('соль') || s.contains('перец') || s.contains('сахар') || s.contains('разрыхл') || s.contains('спец') || s.contains('карри') || s.contains('паприк') ||
        s.contains('тимьян') || s.contains('тмин') || s.contains('кориандр') || s.contains('базилик')) {
      return 'assets/images/salt.png';
    }
    // соусы -> sauces
    if (s.contains('соус') || s.contains('майонез') || s.contains('кетчуп') || s.contains('горчиц') ||
        s.contains('терияки') || s.contains('барбекю') || s.contains('соев') || s.contains('повидл') || s.contains('джем') || s.contains('варень')) {
      return 'assets/images/sauces.png';
    }
    // сырная продукция -> cheese
    if (s.contains('сыр') || s.contains('моцарел') || s.contains('пармез') || s.contains('брынз') || s.contains('фет') ||
        s.contains('творог')) {
      return 'assets/images/cheese.png';
    }
    // по умолчанию без ассета — будет показан Material Icon
    return null;
  }

  List<String> _parseInstructions(Map<String, dynamic> obj) {
    final List<String> out = [];
    final steps = obj['instructions'];
    if (steps is List) {
      steps.sort((a, b) {
        final sa = (a is Map) ? (a['step_number'] as int? ?? 0) : 0;
        final sb = (b is Map) ? (b['step_number'] as int? ?? 0) : 0;
        return sa.compareTo(sb);
      });
      for (final s in steps) {
        if (s is Map) {
          final text = (s['text'] as String?)?.trim();
          if (text != null && text.isNotEmpty) out.add(text);
        }
      }
    }
    return out;
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
            title: _title,
            nutrition: _nutrition,
            imageAsset: _imageAsset,
            imageUrl: _imageUrl,
            ingredients: _ingredients,
            favorite: isFavorite,
            onFavoriteTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            onStartCooking: () {
              context.push('/recipe/steps', extra: {
                'title': _title,
                'nutrition': _nutrition,
                'imageAsset': _imageAsset,
                'steps': _steps,
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