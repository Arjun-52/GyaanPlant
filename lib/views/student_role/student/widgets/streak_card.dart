import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.1, end: 0.35).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF261202), Color(0xFF0F0701)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA726).withValues(alpha: _glowAnim.value),
                blurRadius: 20,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glowing Flame icon wrapper
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x22FFA726),
              border: Border.all(
                color: const Color(0xFFFFA726).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: const Text(
              "🔥",
              style: TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 16),
          // Streak progress details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      "14-Day Streak!",
                      style: TextStyle(
                        color: Color(0xFFFFA726),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFA726),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Complete today's task — Day 15 reward: Free Mock Interview",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Premium day timeline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dayBox("M", true),
                    _dayBox("T", true),
                    _dayBox("W", true),
                    _dayBox("T", true),
                    _dayBox("F", true),
                    _dayBox("S", false),
                    _dayBox("S", false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayBox(String day, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive ? const Color(0xFFFFA726) : const Color(0xFF1E1E1E),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.white10,
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        day,
        style: TextStyle(
          color: isActive ? const Color(0xFF0F0701) : Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
