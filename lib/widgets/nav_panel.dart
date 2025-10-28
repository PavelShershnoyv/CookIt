import 'package:flutter/material.dart';

class NavPanel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const NavPanel({super.key, this.selectedIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x1A000000),
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavItem(
              assetPath: 'assets/images/fridge.png',
              selected: selectedIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            const SizedBox(width: 32),
            _NavItem(
              assetPath: 'assets/images/scanner.png',
              selected: selectedIndex == 2,
              onTap: () => onTap?.call(2),
            ),
            const SizedBox(width: 32),
            _NavItem(
              assetPath: 'assets/images/recipes.png',
              selected: selectedIndex == 1,
              onTap: () => onTap?.call(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String assetPath;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.assetPath,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Размеры и паддинги
    final double iconSize = selected ? 38 : 32; // как было
    final double paddingAroundIcon = selected ? 14 : 10; // 14px для выбранного
    final double circleSize = iconSize + paddingAroundIcon * 2;

    // Цвет фона круга
    final Color circleColor =
        selected ? const Color(0xFFB3F800) : const Color(0xFF171717);

    // Выбор ассета: для выбранного используем *_black
    final String displayedAsset =
        selected ? assetPath.replaceFirst('.png', '_black.png') : assetPath;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: circleSize,
        height: circleSize,
        child: Container(
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Image.asset(
              displayedAsset,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
