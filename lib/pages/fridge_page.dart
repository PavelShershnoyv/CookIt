import 'package:flutter/material.dart';
import 'package:cookit/design/colors.dart';
import 'package:cookit/widgets/nav_panel.dart';
import 'package:go_router/go_router.dart';

class FridgePage extends StatelessWidget {
  const FridgePage({super.key});

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
              const _SearchField(),
              const SizedBox(height: 24),
              _ItemsGrid(),
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
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1F000000),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0x80FFFFFF)),
          SizedBox(width: 8),
          Text(
            'Поиск',
            style: TextStyle(
              color: Color(0x80FFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemData {
  final String title;
  final String amount;
  final IconData icon;
  const _ItemData(
      {required this.title, required this.amount, required this.icon});
}

class _ItemsGrid extends StatefulWidget {
  const _ItemsGrid();

  @override
  State<_ItemsGrid> createState() => _ItemsGridState();
}

class _ItemsGridState extends State<_ItemsGrid> {
  late List<_ItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      const _ItemData(title: 'Молоко', amount: '1 л', icon: Icons.local_drink),
      const _ItemData(
          title: 'Оливковое масло',
          amount: '500 мл',
          icon: Icons.invert_colors),
      const _ItemData(
          title: 'Яйцо', amount: '10 шт', icon: Icons.emoji_food_beverage),
      const _ItemData(title: 'Яблоко', amount: '5 шт', icon: Icons.spa),
      const _ItemData(title: 'Лимон', amount: '2 шт', icon: Icons.circle),
      const _ItemData(
          title: 'Куринное филе', amount: '200 г', icon: Icons.set_meal),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final index = i; // закрепляем индекс для замыкания
      children.add(
        _FridgeItem(
          title: item.title,
          amount: item.amount,
          icon: item.icon,
          onDelete: () {
            setState(() {
              _items.removeAt(index);
            });
          },
        ),
      );
      if (index + 1 < _items.length) {
        children.add(const SizedBox(height: 12));
      }
    }
    return Column(children: children);
  }
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
  final String amount;
  final IconData icon;
  final VoidCallback onDelete;

  const _FridgeItem(
      {required this.title,
      required this.amount,
      required this.icon,
      required this.onDelete});

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
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFFDADADA),
                    fontSize: 14,
                  ),
                ),
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
