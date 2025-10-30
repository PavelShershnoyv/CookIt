import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FridgeItem {
  final String title;
  final String amount;
  final IconData icon;
  FridgeItem({required this.title, required this.amount, required this.icon});
}

class FridgeStore {
  FridgeStore._internal() {
    // Инициализируем стартовым набором, как было в FridgePage
    _itemsNotifier.value = [
      FridgeItem(title: 'Молоко', amount: '1 л', icon: Icons.local_drink),
      FridgeItem(title: 'Оливковое масло', amount: '500 мл', icon: Icons.invert_colors),
      FridgeItem(title: 'Яйцо', amount: '10 шт', icon: Icons.emoji_food_beverage),
      FridgeItem(title: 'Яблоко', amount: '5 шт', icon: Icons.spa),
      FridgeItem(title: 'Лимон', amount: '2 шт', icon: Icons.circle),
      FridgeItem(title: 'Куринное филе', amount: '200 г', icon: Icons.set_meal),
    ];
  }

  static final FridgeStore instance = FridgeStore._internal();

  final ValueNotifier<List<FridgeItem>> _itemsNotifier = ValueNotifier<List<FridgeItem>>([]);

  ValueListenable<List<FridgeItem>> get itemsListenable => _itemsNotifier;
  List<FridgeItem> get items => List.unmodifiable(_itemsNotifier.value);

  void add(FridgeItem item) {
    final current = List<FridgeItem>.from(_itemsNotifier.value);
    // Не добавляем дубликаты по названию (без учета регистра)
    final exists = current.any((e) => e.title.trim().toLowerCase() == item.title.trim().toLowerCase());
    if (!exists) {
      current.add(item);
      _itemsNotifier.value = current;
    }
  }

  void addAll(Iterable<FridgeItem> items) {
    final current = List<FridgeItem>.from(_itemsNotifier.value);
    for (final item in items) {
      final exists = current.any((e) => e.title.trim().toLowerCase() == item.title.trim().toLowerCase());
      if (!exists) {
        current.add(item);
      }
    }
    _itemsNotifier.value = current;
  }

  void removeAt(int index) {
    final current = List<FridgeItem>.from(_itemsNotifier.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _itemsNotifier.value = current;
    }
  }

  void clear() {
    _itemsNotifier.value = [];
  }

  // Небольшой хелпер для определения иконки по названию
  IconData iconForName(String raw) {
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