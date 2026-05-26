import 'package:flutter/material.dart';
import 'package:gyaanplant/models/assessment/mock_test_models.dart';
import 'package:gyaanplant/views/student_role/Test_/screens/prep_pack_details_screen.dart';

class TestPackCard extends StatelessWidget {
  final PreparationPackModel pack;

  const TestPackCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    // 1. Difficulty Color Mapping
    Color difficultyColor;
    switch (pack.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      case 'mixed':
        difficultyColor = Colors.purple;
        break;
      default:
        difficultyColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07241A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Row: Difficulty Chip & Gold Premium Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: difficultyColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  pack.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (pack.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    "PREMIUM",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            pack.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Tags section (Hide if empty)
          if (pack.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pack.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Price section
          Row(
            children: [
              Text(
                "₹${pack.price}",
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white24, size: 12),
              const SizedBox(width: 8),
              Text(
                "₹${pack.discountedPrice}",
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${pack.discountPercentage}% OFF",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 0.8,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),

          // Stats grid row (Sections, Questions, Duration)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SECTIONS", style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      "${pack.sections.length}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("QUESTIONS", style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      "${pack.totalQuestions}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DURATION", style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      pack.totalDurationMins == 0 ? "--" : "${pack.totalDurationMins} min",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 0.8,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),

          // Bottom metrics summary row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricPill("${pack.attempts} ATTEMPTS"),
                const SizedBox(width: 8),
                _buildMetricPill("${pack.completions} COMPLETED"),
                const SizedBox(width: 8),
                _buildMetricPill("${pack.avgScore.round()}% AVG SCORE"),
                const SizedBox(width: 8),
                _buildMetricPill("Pass ${pack.passingScore.round()}% required", isAccent: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button (Navigate to PrepPackDetailsScreen)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrepPackDetailsScreen(packId: pack.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                pack.hasAccess ? "CONTINUE" : "UNLOCK PACK",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent ? const Color(0xFF00C853).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAccent ? const Color(0xFF00C853).withValues(alpha: 0.25) : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAccent ? const Color(0xFF00E676) : Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
