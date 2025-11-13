class RecipeSummary {
  final int id;
  final String title;
  final String? categoryName;
  final String? cuisineName;
  final String? poster;
  final String? difficulty;
  final String? cooktime;
  final bool? vegan;
  final String? createdAt;
  final int? matchCount;
  final List<String> matchedIngredients;

  const RecipeSummary({
    required this.id,
    required this.title,
    this.categoryName,
    this.cuisineName,
    this.poster,
    this.difficulty,
    this.cooktime,
    this.vegan,
    this.createdAt,
    this.matchCount,
    this.matchedIngredients = const [],
  });

  factory RecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecipeSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? 'Рецепт',
      categoryName: (json['category_name'] as String?)?.trim(),
      cuisineName: (json['cuisine_name'] as String?)?.trim(),
      poster: (json['poster'] as String?)?.trim(),
      difficulty: (json['difficulty'] as String?)?.trim(),
      cooktime: (json['cooktime'] as String?)?.trim(),
      vegan: json['vegan'] as bool?,
      createdAt: (json['created_at'] as String?)?.trim(),
      matchCount: (json['match_count'] as num?)?.toInt(),
      matchedIngredients: ((json['matched_ingredients'] as List?)
              ?.whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()) ??
          const [],
    );
  }
}