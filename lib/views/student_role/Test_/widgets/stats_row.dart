import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TestViewModel>();
    final stats = vm.stats;

    final correct = stats?.correct ?? 0;
    final wrong = stats?.wrong ?? 0;
    final remaining = stats?.remaining ?? 0;
    final accuracy = stats?.accuracy ?? 0;

    return Row(
      children: [
        Expanded(
          child: _PremiumStatCard(
            value: correct,
            label: "Correct",
            suffix: "",
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF00E676),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PremiumStatCard(
            value: wrong,
            label: "Wrong",
            suffix: "",
            icon: Icons.cancel_outlined,
            color: const Color(0xFFFF5252),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PremiumStatCard(
            value: remaining,
            label: "Remaining",
            suffix: "",
            icon: Icons.hourglass_bottom_rounded,
            color: const Color(0xFF448AFF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PremiumStatCard(
            value: accuracy,
            label: "Accuracy",
            suffix: "%",
            icon: Icons.track_changes_rounded,
            color: const Color(0xFFFFAB40),
          ),
        ),
      ],
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final int value;
  final String label;
  final String suffix;
  final IconData icon;
  final Color color;

  const _PremiumStatCard({
    required this.value,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C241E),
            Color(0xFF071A14),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              return Text(
                "$animValue$suffix",
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
