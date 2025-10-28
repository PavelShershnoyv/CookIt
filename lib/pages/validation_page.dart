import 'package:flutter/material.dart';
import 'package:cookit/design/colors.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final List<_Item> _items = [
    _Item('Яйцо', Icons.egg, 7),
    _Item('Молоко', Icons.local_drink, 1),
    _Item('Оливковое масло', Icons.invert_colors, 1),
    _Item('Лимон', Icons.emoji_food_beverage, 5),
    _Item('Яблоко', Icons.apple, 7),
  ];

  void _inc(int index) => setState(() => _items[index].count++);
  void _dec(int index) => setState(() {
        if (_items[index].count > 0) _items[index].count--;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Фото холодильника с затемнением снизу
              SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/fridge.png',
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Валидация',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Пожалуйста, подтвердите\nраспознанные продукты',
                      style: TextStyle(
                        color: Color(0xFFB3F800),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Список распознанных продуктов
                    for (int i = 0; i < _items.length; i++) ...[
                      _ValidationRow(
                        title: _items[i].name,
                        icon: _items[i].icon,
                        count: _items[i].count,
                        onMinus: () => _dec(i),
                        onPlus: () => _inc(i),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Кнопка "Добавить продукт"
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x1F000000),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Добавить продукт',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Нижняя панель действий
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Отмена',
                            backgroundColor: const Color(0x1F000000),
                            textColor: Colors.white,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Продолжить',
                            backgroundColor: const Color(0xFFB3F800),
                            textColor: Colors.black,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _ValidationRow({
    required this.title,
    required this.icon,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x332D2D2D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleButton(label: '-', onTap: onMinus, filled: false),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _CircleButton(label: '+', onTap: onPlus, filled: true),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _CircleButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFFB3F800) : const Color(0x1F000000);
    final fg = filled ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final String name;
  final IconData icon;
  int count;
  _Item(this.name, this.icon, this.count);
}