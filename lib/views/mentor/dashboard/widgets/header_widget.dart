import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF140A2E), Color(0xFF1A0033)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24), // 👈 only bottom rounded
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Mentor Dashboard",
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Rahul Singh",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB388FF),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "SDE-2 @ Amazon · GRIET 2022",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),

              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                ),
                child: const Center(
                  child: Text(
                    "RS",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ///  STATS ROW
          Row(
            children: const [
              Expanded(
                child: HeaderStatCard("24", "Sessions Done", Colors.purple),
              ),
              SizedBox(width: 10),
              Expanded(
                child: HeaderStatCard("₹9,600", "Earned (Mar)", Colors.orange),
              ),
              SizedBox(width: 10),
              Expanded(child: HeaderStatCard("4.9 ⭐", "Rating", Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const HeaderStatCard(this.value, this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        /// subtle glow
        color: color.withOpacity(0.12),

        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
