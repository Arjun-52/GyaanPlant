import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  Widget statBox(String value, String label, Color color) {
    return Container(
      height: 80, 
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green, width: 0.4),
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
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TestViewModel>();
    final stats = vm.stats;

    final correct = stats != null ? "${stats.correct}" : "0";
    final wrong = stats != null ? "${stats.wrong}" : "0";
    final remaining = stats != null ? "${stats.remaining}" : "0";
    final accuracy = stats != null ? "${stats.accuracy}%" : "0%";

    return Row(
      children: [
        Expanded(child: statBox(correct, "Correct", Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: statBox(wrong, "Wrong", Colors.red)),
        const SizedBox(width: 8),
        Expanded(child: statBox(remaining, "Remaining", Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: statBox(accuracy, "Accuracy", Colors.orange)),
      ],
    );
  }
}
