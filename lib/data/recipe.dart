class Recipe {
  final int id;
  final String name;
  final String sastav;
  final String instruction;
  final String? podcategory;
  final int? category;

  const Recipe({
    required this.id,
    required this.name,
    required this.sastav,
    required this.instruction,
    this.podcategory,
    this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id_recepts'] as num?)?.toInt() ?? 0,
      name: (json['recept_name'] as String?)?.trim() ?? 'Рецепт',
      sastav: (json['recept_sostav'] as String?)?.trim() ?? '',
      instruction: (json['recept_instuction'] as String?)?.trim() ?? '',
      podcategory: (json['podcategory'] as String?)?.trim(),
      category: (json['recept_category'] as num?)?.toInt(),
    );
  }
}