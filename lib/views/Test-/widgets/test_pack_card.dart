import 'package:flutter/material.dart';

class TestPackCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color priceColor;

  const TestPackCard(
    this.title,
    this.subtitle,
    this.price,
    this.priceColor, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        color: Color(0xFF0A2F24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          //  LEFT ICON BOX
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: const Text("📄", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),

          //  TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          //  PRICE TAG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: priceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
