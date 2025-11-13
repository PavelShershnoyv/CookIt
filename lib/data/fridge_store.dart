import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Общая логика иконок теперь определяется на уровне страниц (IngredientIcons)

class FridgeItem {
  final String title;
  final String amount;
  final IconData icon;
  final String? iconAsset;
  FridgeItem({required this.title, required this.amount, required this.icon, this.iconAsset});
}

class FridgeStore {
  FridgeStore._internal() {
    // Холодильник по умолчанию пуст. Загружаем сохранённые данные, если они есть.
    _loadFromPrefs();
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
      _saveToPrefs();
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
    _saveToPrefs();
  }

  void removeAt(int index) {
    final current = List<FridgeItem>.from(_itemsNotifier.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _itemsNotifier.value = current;
      _saveToPrefs();
    }
  }

  void clear() {
    _itemsNotifier.value = [];
    _saveToPrefs();
  }

  // Локальная маппинга иконок по названию больше не требуется.

  // --- Persistence ---
  // Переходим на новый ключ, чтобы игнорировать старые сохранённые данные
  static const String _prefsKey = 'fridge_items_v2';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr == null || jsonStr.isEmpty) return;
      final List<dynamic> rawList = jsonDecode(jsonStr) as List<dynamic>;
      final List<FridgeItem> loaded = rawList.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final title = (m['title'] as String?) ?? '';
        final amount = (m['amount'] as String?) ?? '—';
        final codePoint = (m['icon'] as int?) ?? Icons.check_circle_outline.codePoint;
        final iconAsset = m['iconAsset'] as String?;
        return FridgeItem(
          title: title,
          amount: amount,
          icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
          iconAsset: iconAsset,
        );
      }).toList();
      _itemsNotifier.value = loaded;
    } catch (_) {
      // Игнорируем ошибки чтения/парсинга, оставляем пустой список
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _itemsNotifier.value
          .map((e) => {
                'title': e.title,
                'amount': e.amount,
                'icon': e.icon.codePoint,
                'iconAsset': e.iconAsset,
              })
          .toList();
      final jsonStr = jsonEncode(data);
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {
      // Молча игнорируем ошибки сохранения
    }
  }
}