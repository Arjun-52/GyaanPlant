import 'package:flutter/material.dart';
import 'test_pack_card.dart';
import 'package:gyaanplant/models/assessment/mock_test_models.dart';
import 'package:gyaanplant/core/unlocked_packs_cache.dart';

class UpcomingTests extends StatefulWidget {
  const UpcomingTests({super.key});

  @override
  State<UpcomingTests> createState() => _UpcomingTestsState();
}

class _UpcomingTestsState extends State<UpcomingTests> {
  late List<PreparationPackModel> _packs;

  @override
  void initState() {
    super.initState();
    _packs = [
      PreparationPackModel(
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
      PreparationPackModel(
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
      PreparationPackModel(
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
    ];
  }

  void _handleReturn(String packId) {
    // Mark pack as unlocked locally to reflect immediate UI change.
    final idx = _packs.indexWhere((p) => p.id == packId);
    if (idx == -1) return;
    final p = _packs[idx];
    _packs[idx] = PreparationPackModel(
      id: p.id,
      title: p.title,
      price: p.price,
      difficulty: p.difficulty,
      isPremium: p.isPremium,
      discountedPrice: p.discountedPrice,
      discountPercentage: p.discountPercentage,
      sections: p.sections,
      totalQuestions: p.totalQuestions,
      totalDurationMins: p.totalDurationMins,
      attempts: p.attempts,
      completions: p.completions,
      avgScore: p.avgScore,
      passingScore: p.passingScore,
      hasAccess: true,
      tags: p.tags,
    );
    setState(() {});
    // Record unlocked pack globally so other views show updated state immediately
    UnlockedPacksCache.add(packId);
  }

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

        for (final pack in _packs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TestPackCard(
              pack: pack,
              onReturn: () => _handleReturn(pack.id),
            ),
          ),
      ],
    );
  }
}