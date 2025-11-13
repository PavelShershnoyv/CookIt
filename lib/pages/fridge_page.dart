import 'package:flutter/material.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:cookit/data/fridge_store.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  String _query = '';
  late final TextEditingController _fridgeSearchController;

  @override
  void initState() {
    super.initState();
    _fridgeSearchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _fridgeSearchController.dispose();
    super.dispose();
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
              const _Title(),
              const SizedBox(height: 12),
              const _FiltersRow(),
              const SizedBox(height: 16),
              _SearchField(
                controller: _fridgeSearchController,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 24),
              _ItemsGrid(query: _query),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavPanel(
        selectedIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // already on fridge
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

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Холодильник',
      style: TextStyle(
        color: textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _FilterChip(label: 'Все', selected: true),
          SizedBox(width: 8),
          _FilterChip(label: 'Мясо'),
          SizedBox(width: 8),
          _FilterChip(label: 'Фрукты'),
          SizedBox(width: 8),
          _FilterChip(label: 'Овощи'),
          SizedBox(width: 8),
          _FilterChip(label: 'Молочное'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFB3F800) : const Color(0x1F000000),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : const Color(0xFFFDFEFF),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

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
                hintText: 'Поиск',
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

class _ItemData {
  final String title;
  final IconData icon;
  const _ItemData({required this.title, required this.icon});
}

class _ItemsGrid extends StatefulWidget {
  final String query;
  const _ItemsGrid({this.query = ''});

  @override
  State<_ItemsGrid> createState() => _ItemsGridState();
}

class _ItemsGridState extends State<_ItemsGrid> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<FridgeItem>>(
      valueListenable: FridgeStore.instance.itemsListenable,
      builder: (context, items, _) {
        final q = _normalize(widget.query);
        final filtered = q.isEmpty
            ? items
            : items.where((i) => _matchesByWordPrefix(i.title, q)).toList();
        final List<Widget> children = [];
        for (int i = 0; i < filtered.length; i++) {
          final item = filtered[i];
          final index = i;
          children.add(
            _FridgeItem(
              title: item.title,
              icon: item.icon,
              onDelete: () {
                FridgeStore.instance.removeAt(index);
              },
            ),
          );
          if (index + 1 < filtered.length) {
            children.add(const SizedBox(height: 12));
          }
        }
        return Column(children: children);
      },
    );
  }
}

String _normalize(String s) {
  var t = s.toLowerCase();
  t = t.replaceAll(RegExp(r'[^a-zA-Zа-яА-Я0-9\s]'), '');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t;
}

// Совпадение по префиксу слова: хотя бы одно слово в названии
// начинается с введённой последовательности. Для многословного запроса
// каждый токен должен совпасть с префиксом какого-либо слова.
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

class _ItemRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ItemRow({required this.left, required this.right});

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

class _FridgeItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onDelete;

  const _FridgeItem(
      {required this.title, required this.icon, required this.onDelete});

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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x332D2D2D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Количество убрано по требованиям: остаётся только название
              ],
            ),
          ),
          const SizedBox(width: 8),
          _TrashButton(onPressed: onDelete),
        ],
      ),
    );
  }
}

class _TrashButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _TrashButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFB3F800),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.delete,
            color: Colors.black,
            size: 22,
          ),
        ),
      ),
    );
  }
}
