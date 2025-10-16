import 'package:cookit/design/colors.dart';
import 'package:cookit/design/dimensions.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String time;
  final int ingredientsOwned;
  final int ingredientsTotal;
  final bool favorite;

  const RecipeCard({
    super.key,
    required this.title,
    required this.time,
    required this.ingredientsOwned,
    required this.ingredientsTotal,
    this.favorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: textPrimary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius30),
                    topRight: Radius.circular(radius30)),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gradientStart,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'У вас ${ingredientsOwned}/${ingredientsTotal}',
                  style: const TextStyle(color: background, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0x332D2D2D),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius30),
              bottomRight: Radius.circular(radius30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFFDADADA),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.favorite,
                color: favorite ? gradientStart : Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
