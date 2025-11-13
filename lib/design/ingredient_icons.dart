import 'package:flutter/material.dart';

/// Общий маппинг иконок ингредиентов для единообразия между страницами.
class IngredientIcons {
  /// Возвращает путь к ассету картинки для ингредиента, если найдено соответствие.
  /// Иконки совпадают с теми, что используются на странице рецепта.
  static String? iconAssetForName(String name) {
    final s = name.toLowerCase();
    // мучное -> bread
    if (s.contains('мука') || s.contains('макарон') || s.contains('спагет') || s.contains('лапш') ||
        s.contains('тесто') || s.contains('пицц') || s.contains('хлеб') || s.contains('булк') || s.contains('батон') ||
        s.contains('лаваш') || s.contains('тортиль') || s.contains('дрожж') || s.contains('крахмал')) {
      return 'assets/images/bread.png';
    }
    // мясо -> meet
    if (s.contains('мяс') || s.contains('говядин') || s.contains('свинин') || s.contains('баранин') ||
        s.contains('куриц') || s.contains('кури') || s.contains('курин') || s.contains('индейк') || s.contains('утк') || s.contains('ветчин') || s.contains('колбас')) {
      return 'assets/images/meet.png';
    }
    // рыба -> fish
    if (s.contains('рыб') || s.contains('лосос') || s.contains('тунец') || s.contains('хек') || s.contains('сельд') ||
        s.contains('минтай') || s.contains('семг') || s.contains('скумбр')) {
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
    if (s.contains('масло') || s.contains('оливков') || s.contains('подсолнеч') || s.contains('водк')) {
      return 'assets/images/oil.png';
    }
    // фрукты/ягоды -> apple
    if (s.contains('яблок') || s.contains('банан') || s.contains('апельсин') || s.contains('лимон') || s.contains('лайм') ||
        s.contains('груш') || s.contains('персик') || s.contains('виноград') || s.contains('киви') ||
        s.contains('малина') || s.contains('ягод') || s.contains('клубник') || s.contains('черник') || s.contains('голубик') || s.contains('брусник') || s.contains('клюкв') || s.contains('ежевик') || s.contains('смородин')) {
      return 'assets/images/apple.png';
    }
    // овощи/зелень -> carrot
    if (s.contains('капуст') || s.contains('огур') || s.contains('лук') || s.contains('помидор') || s.contains('томат') ||
        s.contains('картоф') || s.contains('морков') || s.contains('перец') || s.contains('кабач') || s.contains('баклаж') ||
        s.contains('свекл') || s.contains('укроп') || s.contains('петруш') || s.contains('зелень') || s.contains('шпинат')) {
      return 'assets/images/carrot.png';
    }
    // специи -> salt
    if (s.contains('соль') || s.contains('перец') || s.contains('сахар') || s.contains('разрыхл') || s.contains('спец') || s.contains('карри') || s.contains('паприк') ||
        s.contains('тимьян') || s.contains('тмин') || s.contains('кориандр') || s.contains('базилик') || s.contains('сода') || s.contains('корица')) {
      return 'assets/images/salt.png';
    }
    // соусы/джемы -> sauces
    if (s.contains('соус') || s.contains('майонез') || s.contains('кетчуп') || s.contains('горчиц') ||
        s.contains('терияки') || s.contains('барбекю') || s.contains('соев') || s.contains('повидл') || s.contains('джем') || s.contains('варень')) {
      return 'assets/images/sauces.png';
    }
    // сырная продукция -> cheese
    if (s.contains('сыр') || s.contains('моцарел') || s.contains('пармез') || s.contains('брынз') || s.contains('фет') ||
        s.contains('творог')) {
      return 'assets/images/cheese.png';
    }
    return null;
  }

  /// Определение пользовательской категории для фильтров холодильника
  /// Возвращает одну из: 'Мясо', 'Фрукты', 'Овощи', 'Молочное', либо null
  static String? categoryForName(String name) {
    final asset = iconAssetForName(name);
    if (asset == null) return null;
    if (asset.endsWith('/meet.png')) return 'Мясо';
    if (asset.endsWith('/apple.png')) return 'Фрукты';
    if (asset.endsWith('/carrot.png')) return 'Овощи';
    if (asset.endsWith('/milk.png')) return 'Молочное';
    return null;
  }

  /// Запасной вариант: Material Icons, если ассет не найден.
  static IconData fallbackIconForName(String raw) {
    final name = raw.trim().toLowerCase();
    switch (name) {
      case 'яблоко':
        return Icons.apple;
      case 'лимон':
        return Icons.emoji_food_beverage;
      case 'яйцо':
        return Icons.egg;
      case 'молоко':
        return Icons.local_drink;
      case 'оливковое масло':
        return Icons.invert_colors;
      case 'помидоры':
      case 'помидор':
        return Icons.local_pizza;
      case 'шпинат':
        return Icons.eco;
      case 'курица':
      case 'мясо':
      case 'куринное филе':
        return Icons.set_meal;
      case 'морковь':
        return Icons.local_florist;
      default:
        return Icons.check_circle_outline;
    }
  }
}