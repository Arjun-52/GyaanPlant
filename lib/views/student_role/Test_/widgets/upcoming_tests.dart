import 'package:flutter/material.dart';
import 'test_pack_card.dart';
import 'package:gyaanplant/models/assessment/mock_test_models.dart';

class UpcomingTests extends StatelessWidget {
  const UpcomingTests({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Test Packs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),

        TestPackCard(
          pack: PreparationPackModel(
            id: '1',
            title: "TCS NQT Full Mock",
            price: 299,
            difficulty: "medium",
            isPremium: true,
            discountedPrice: 199,
            discountPercentage: 33,
            sections: const [],
            totalQuestions: 80,
            totalDurationMins: 90,
            attempts: 1200,
            completions: 950,
            avgScore: 68.5,
            passingScore: 60.0,
            hasAccess: false,
            tags: const ["TCS", "NQT", "Mock"],
          ),
        ),

        TestPackCard(
          pack: PreparationPackModel(
            id: '2',
            title: "Infosys InfyTQ Prep",
            price: 249,
            difficulty: "easy",
            isPremium: false,
            discountedPrice: 149,
            discountPercentage: 40,
            sections: const [],
            totalQuestions: 60,
            totalDurationMins: 60,
            attempts: 800,
            completions: 720,
            avgScore: 72.0,
            passingScore: 65.0,
            hasAccess: true,
            tags: const ["Infosys", "InfyTQ"],
          ),
        ),

        TestPackCard(
          pack: PreparationPackModel(
            id: '3',
            title: "Wipro NLTH Pack",
            price: 279,
            difficulty: "hard",
            isPremium: true,
            discountedPrice: 179,
            discountPercentage: 35,
            sections: const [],
            totalQuestions: 100,
            totalDurationMins: 120,
            attempts: 1500,
            completions: 1100,
            avgScore: 61.2,
            passingScore: 55.0,
            hasAccess: false,
            tags: const ["Wipro", "NLTH"],
          ),
        ),
      ],
    );
  }
}