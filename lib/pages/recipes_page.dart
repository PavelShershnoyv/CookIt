import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:cookit/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/design/images.dart';
import 'package:cookit/widgets/recipe_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:cookit/data/recipe_summary.dart';
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
  List<RecipeSummary> _recipes = const [];
  final Map<int, List<String>> _ingredientNamesById = {};
  String _query = '';
  late final TextEditingController _recipesSearchController;
  late final ScrollController _scrollController;
  int _pageSize = 30;
  int _offset = 0;
  bool _fetchingMore = false;
  bool _hasMore = true;
  Timer? _searchDebounce;
  bool _isServerSearch = false;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    // Инициализируем выбранный фильтр из параметра навигации, если он валиден
    const allowed = ['Все', 'Доступные', 'Завтрак', 'Обед', 'Ужин', 'Десерт'];
    final init = widget.initialSelected;
    if (init != null && allowed.contains(init)) {
      _selected = init;
    }
    _recipesSearchController = TextEditingController(text: _query);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchRecipes();
  }

  @override
  void dispose() {
    _recipesSearchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchIngredientsForSummaries(
      List<RecipeSummary> summaries) async {
    for (final r in summaries) {
      try {
        final uri = Uri.parse('http://121.127.37.220:8000/recipes/${r.id}');
        final res =
            await http.get(uri, headers: {'accept': 'application/json'});
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final decoded = jsonDecode(res.body);
          Map<String, dynamic>? obj;
          if (decoded is Map<String, dynamic>) {
            obj = decoded;
          } else if (decoded is List &&
              decoded.isNotEmpty &&
              decoded.first is Map<String, dynamic>) {
            obj = decoded.first as Map<String, dynamic>;
          }
          final names = _extractIngredientNames(obj);
          if (names.isNotEmpty) {
            setState(() {
              _ingredientNamesById[r.id] = names;
            });
          }
        }
      } catch (_) {
        // ignore errors per item
      }
    }
  }

  List<String> _extractIngredientNames(Map<String, dynamic>? obj) {
    if (obj == null) return const [];
    // Популярные поля для состава
    final candidates = [
      obj['ingredients'],
      obj['sastav'],
      obj['recept_sostav'],
    ];
    for (final v in candidates) {
      if (v is List) {
        return v
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (v is String) {
        final parts = v.split(RegExp(r'[;,\n]'));
        return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return const [];
  }

  void _onScroll() {
    // Во время серверного поиска не догружаем пагинацию
    if (_isServerSearch) return;
    if (!_hasMore || _fetchingMore) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      unawaited(_loadMoreRecipes());
    }
  }

  void _handleQueryChanged(String v) {
    setState(() {
      _query = v;
    });
    _searchDebounce?.cancel();
    final q = v.trim();
    if (q.isEmpty || q.length < 2) {
      _isServerSearch = false;
      // Небольшой дебаунс, чтобы не дёргать загрузку при очистке
      _searchDebounce = Timer(const Duration(milliseconds: 200), () {
        _fetchRecipes();
      });
    } else {
      _isServerSearch = true;
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        unawaited(_searchRecipesPaged(q));
      });
    }
  }

  Future<void> _searchRecipesPaged(String q) async {
    final mySeq = ++_searchSeq;
    try {
      setState(() {
        _loading = true;
        _error = null;
        _hasMore = false; // при серверном поиске пагинация отключена
        _recipes = const [];
        _offset = 0;
      });
      final encoded = Uri.encodeComponent(q);
      final base =
          Uri.parse('http://121.127.37.220:8000/recipes/search/$encoded');
      // 5 последовательных запросов: 3000, 6000, 9000, 12000, 15000
      for (int i = 1; i <= 5; i++) {
        if (!mounted || mySeq != _searchSeq)
          break; // отмена, если запрос устарел
        final limit = i * 3000;
        final uri = base.replace(queryParameters: {'limit': '$limit'});
        debugPrint('RecipesPage: search GET $uri');
        if (i > 1) {
          setState(() => _fetchingMore = true);
        }
        final res =
            await http.get(uri, headers: {'accept': 'application/json'});
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final decoded = jsonDecode(res.body);
          List<dynamic> data;
          if (decoded is List) {
            data = decoded;
          } else if (decoded is Map<String, dynamic>) {
            final keys = ['data', 'results', 'recipes', 'items'];
            List<dynamic>? found;
            for (final k in keys) {
              final v = decoded[k];
              if (v is List) {
                found = v;
                break;
              }
            }
            data = found ?? <dynamic>[];
            if (data.isEmpty) {
              data = [decoded];
            }
          } else {
            data = <dynamic>[];
          }

          final fetched = data
              .whereType<Map<String, dynamic>>()
              .map((j) => RecipeSummary.fromJson(j))
              .toList();
          final existingIds = _recipes.map((r) => r.id).toSet();
          final uniqueNew =
              fetched.where((r) => !existingIds.contains(r.id)).toList();
          if (!mounted || mySeq != _searchSeq) break;
          setState(() {
            _recipes = List.of(_recipes)..addAll(uniqueNew);
            _offset = _recipes.length;
            _loading = false; // снимаем основной лоадер после первого ответа
            _fetchingMore = false;
          });
        } else {
          throw Exception('HTTP ${res.statusCode}: ${res.body}');
        }
      }
    } catch (e) {
      if (!mounted || mySeq != _searchSeq) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _fetchingMore = false;
      });
    }
  }

  Future<void> _searchRecipes(String q) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
        _hasMore = false; // при серверном поиске пагинация отключена
      });
      // Кодируем сегмент пути
      final encoded = Uri.encodeComponent(q);
      final base =
          Uri.parse('http://121.127.37.220:8000/recipes/search/$encoded');
      final uri = base.replace(queryParameters: {'limit': '15000'});
      debugPrint('RecipesPage: search GET $uri');
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final keys = ['data', 'results', 'recipes', 'items'];
          List<dynamic>? found;
          for (final k in keys) {
            final v = decoded[k];
            if (v is List) {
              found = v;
              break;
            }
          }
          data = found ?? <dynamic>[];
          if (data.isEmpty) {
            data = [decoded];
          }
        } else {
          data = <dynamic>[];
        }

        final recipes = data
            .whereType<Map<String, dynamic>>()
            .map((j) => RecipeSummary.fromJson(j))
            .toList();
        debugPrint('RecipesPage: search results ${recipes.length}');
        setState(() {
          _recipes = recipes;
          _loading = false;
          _offset = recipes.length;
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

  Future<void> _fetchRecipes() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
        _recipes = const [];
        _ingredientNamesById.clear();
        _offset = 0;
        _hasMore = true;
      });
      final base = Uri.parse('http://121.127.37.220:8000/recipes');
      final uri = base.replace(
        queryParameters: {
          'limit': '$_pageSize',
        },
      );
      debugPrint('RecipesPage: initial GET $uri');
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        // Универсальный разбор: поддерживаем массив и популярные обёртки
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final keys = ['data', 'results', 'recipes', 'items'];
          List<dynamic>? found;
          for (final k in keys) {
            final v = decoded[k];
            if (v is List) {
              found = v;
              break;
            }
          }
          data = found ?? <dynamic>[];
          // Если ключи не подошли, возможно ответ уже одной сущности
          if (data.isEmpty) {
            data = [decoded];
          }
        } else {
          data = <dynamic>[];
        }

        final recipes = data
            .whereType<Map<String, dynamic>>()
            .map((j) => RecipeSummary.fromJson(j))
            .toList();
        debugPrint('RecipesPage: fetched ${recipes.length} recipes (initial)');
        setState(() {
          _recipes = recipes;
          _loading = false;
          _offset = recipes.length;
          _hasMore = recipes.length >= _pageSize;
        });
        // Не подтягиваем подробности здесь, чтобы избежать лишних запросов.
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

  Future<void> _loadMoreRecipes() async {
    if (_fetchingMore || !_hasMore) return;
    setState(() {
      _fetchingMore = true;
    });
    try {
      // Пагинация: пытаемся использовать offset; если бэк игнорирует,
      // мы всё равно добавим только новые рецепты по id.
      final base = Uri.parse('http://121.127.37.220:8000/recipes');
      final requestedLimit = _offset + _pageSize;
      final uri = base.replace(
        queryParameters: {
          'limit': '$requestedLimit',
        },
      );
      debugPrint('RecipesPage: load-more GET $uri');
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final keys = ['data', 'results', 'recipes', 'items'];
          List<dynamic>? found;
          for (final k in keys) {
            final v = decoded[k];
            if (v is List) {
              found = v;
              break;
            }
          }
          data = found ?? <dynamic>[];
          if (data.isEmpty) {
            data = [decoded];
          }
        } else {
          data = <dynamic>[];
        }

        final fetched = data
            .whereType<Map<String, dynamic>>()
            .map((j) => RecipeSummary.fromJson(j))
            .toList();
        final existingIds = _recipes.map((r) => r.id).toSet();
        final uniqueNew =
            fetched.where((r) => !existingIds.contains(r.id)).toList();
        final previousCount = _recipes.length;
        debugPrint(
            'RecipesPage: fetched ${fetched.length}, prev $previousCount, unique new ${uniqueNew.length}');
        if (uniqueNew.isNotEmpty) {
          setState(() {
            _recipes = List.of(_recipes)..addAll(uniqueNew);
            _offset =
                fetched.length; // продвигаем "указатель" на новый общий объём
            _hasMore =
                fetched.length > previousCount; // если объём не вырос — конец
          });
          // Не подтягиваем подробности здесь, чтобы избежать лишних запросов.
        } else {
          setState(() {
            _hasMore = false;
          });
        }
      } else {
        // В случае ошибки прекращаем попытки догружать
        setState(() {
          _hasMore = false;
        });
      }
    } catch (_) {
      setState(() {
        _hasMore = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
              if (_selected == 'Все')
                _RecipesSearchField(
                  controller: _recipesSearchController,
                  onChanged: _handleQueryChanged,
                ),
              if (_selected == 'Все') const SizedBox(height: 16),
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
                      final names = _ingredientNamesById[r.id] ?? const [];
                      final owned = _countOwnedByNames(names, fridgeItems);
                      return _RecipeItem(
                        id: r.id,
                        title: r.title,
                        time: r.cooktime ?? '—',
                        owned: owned,
                        total: names.length,
                        favorite: false,
                        imageUrl: r.poster,
                        category: _mapApiCategoryToUi(r.categoryName),
                        summary: r,
                      );
                    }).toList();

                    // Диагностика: сколько рецептов по категориям
                    final Map<String, int> byCat = {};
                    for (final it in items) {
                      byCat[it.category] = (byCat[it.category] ?? 0) + 1;
                    }
                    debugPrint('RecipesPage: category distribution $byCat');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selected == 'Все') const SizedBox(height: 24),
                        _RecipeGrid(
                          selectedCategory: _selected,
                          onlyAvailable: _selected == 'Доступные',
                          items: items,
                          // При серверном поиске не применяем локальную фильтрацию
                          query: _isServerSearch ? '' : _query,
                        ),
                        if (_fetchingMore) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFB3F800)),
                          ),
                        ],
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
          chip('Доступные'),
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
  final String query;
  const _RecipeGrid(
      {required this.selectedCategory,
      required this.onlyAvailable,
      required this.items,
      this.query = ''});

  @override
  Widget build(BuildContext context) {
    final all = items;

    final base = selectedCategory == 'Все'
        ? all
        : all.where((e) => e.category == selectedCategory).toList();
    final filtered = onlyAvailable
        ? base.where((e) => e.total > 0 && e.owned >= e.total).toList()
        : base;

    final q = _normalize(query);
    final byQuery = q.isEmpty
        ? filtered
        : filtered.where((e) => _matchesByWordPrefix(e.title, q)).toList();

    if (byQuery.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Нет рецептов в этом разделе',
            style: TextStyle(color: Color(0xFFBBBCBC), fontSize: 16),
          ),
        ),
      );
    }

    // Рисуем по двум колонкам c равными отступами между рядами
    final List<Widget> children = [];
    for (int i = 0; i < byQuery.length; i += 2) {
      final left = byQuery[i];
      final right = (i + 1 < byQuery.length) ? byQuery[i + 1] : null;
      children.add(
        _RecipeRow(
          left: _buildCard(context, left),
          right: right != null
              ? _buildCard(context, right)
              : const SizedBox.shrink(),
        ),
      );
      if (i + 2 < byQuery.length) {
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
      imageAsset: null,
      imageUrl: item.imageUrl,
      showIngredientsBadge: selectedCategory == 'Доступные',
      onTap: () => context.push('/recipe', extra: _extrasFor(item)),
    );
  }

  Map<String, dynamic> _extrasFor(_RecipeItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'nutrition': '—',
      'imageAsset': 'assets/images/mock.jpg',
      'favorite': item.favorite,
      // ингредиенты и шаги пока не загружаем: страница использует дефолтные
    };
  }
}

class _RecipeItem {
  final int id;
  final String title;
  final String time;
  final int owned;
  final int total;
  final bool favorite;
  final String? imageAsset;
  final String? imageUrl;
  final String category;
  final RecipeSummary summary;
  _RecipeItem({
    required this.id,
    required this.title,
    required this.time,
    required this.owned,
    required this.total,
    this.favorite = false,
    this.imageAsset,
    this.imageUrl,
    required this.category,
    required this.summary,
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

// Совпадение по префиксу слова: любое слово в названии рецепта
// начинается с введённой последовательности. Для многословного запроса
// требуется, чтобы каждый токен запроса совпадал с префиксом какого-либо слова.
bool _matchesByWordPrefix(String title, String query) {
  final t = _normalize(title);
  final q = _normalize(query);
  if (q.isEmpty) return true;
  final words = t.split(' ');
  final tokens = q.split(' ');
  for (final token in tokens) {
    if (token.isEmpty) continue;
    final hasToken = words.any((w) => w.startsWith(token));
    if (!hasToken) return false;
  }
  return true;
}

bool _nameMatches(String a, String b) {
  final na = _normalize(a);
  final nb = _normalize(b);
  return na == nb || na.contains(nb) || nb.contains(na);
}

int _countOwnedByNames(List<String> names, List<FridgeItem> fridgeItems) {
  int owned = 0;
  for (final n in names) {
    final has = fridgeItems.any((f) => _nameMatches(n, f.title));
    if (has) owned++;
  }
  return owned;
}

String _mapApiCategoryToUi(String? name) {
  final n = (name ?? '').toLowerCase().trim();
  if (n.isEmpty) return 'Все';
  // Русские и английские варианты на всякий случай
  if (n.contains('завтрак') || n.contains('breakfast') || n.contains('утро')) {
    return 'Завтрак';
  }
  if (n.contains('обед') || n.contains('lunch')) {
    return 'Обед';
  }
  if (n.contains('ужин') || n.contains('dinner') || n.contains('вечер')) {
    return 'Ужин';
  }
  if (n.contains('десерт') || n.contains('dessert') || n.contains('слад')) {
    return 'Десерт';
  }
  // Если категория другая — показываем в «Все»
  return 'Все';
}

class _RecipesSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _RecipesSearchField(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1F000000),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0x80FFFFFF)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: Color(0xFFFDFEFF),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Поиск рецептов',
                hintStyle: TextStyle(
                  color: Color(0x80FFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
