import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class BotCard extends StatefulWidget {
  const BotCard({super.key});

  @override
  State<BotCard> createState() => _BotCardState();
}

class _BotCardState extends State<BotCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2A21), Color(0xFF031612)],
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.03),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Icon + Name + Status Pulse)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 18,
                  color: Color(0xFF00E676),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "GyaanBot",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              // AI active status pulse indicator
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(
                            alpha: 0.6 * (1.0 - _pulseAnim.value),
                          ),
                          blurRadius: 8 * _pulseAnim.value,
                          spreadRadius: 3 * _pulseAnim.value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              Text(
                "AI ASSISTANT",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Custom AI advice text inside glass dialogue bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(text: "You're "),
                  TextSpan(
                    text: "13 points away",
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: " from MNC-ready status.\n\nFocus on "),
                  TextSpan(
                    text: "Data Structures",
                    style: TextStyle(
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: " today — it’s your weakest subject and "),
                  TextSpan(
                    text: "TCS",
                    style: TextStyle(
                      color: Color(0xFF29B6F6),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: " tests it heavily in Round 2.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
