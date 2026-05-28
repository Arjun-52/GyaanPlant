import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/views/student_role/student/widgets/ai_advisor_sheet.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  void _showAiAdvisorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AiAdvisorSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "Quick Actions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ActionItem(
                Icons.quiz_rounded,
                "Mock Test",
                glowColor: const Color(0xFF00E676),
                onTap: () {
                  context.read<StudentTabController>().switchTab(2);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionItem(
                Icons.psychology_rounded,
                "AI Advisor",
                glowColor: const Color(0xFFAB47BC),
                onTap: () {
                  _showAiAdvisorSheet(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionItem(
                Icons.work_rounded,
                "Jobs",
                glowColor: const Color(0xFF29B6F6),
                onTap: () {
                  context.read<StudentTabController>().switchTab(3);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionItem(
                Icons.leaderboard_rounded,
                "Leaderboard",
                glowColor: const Color(0xFFFF9800),
                onTap: () {
                  context.push('/leaderboard');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color glowColor;

  const ActionItem(
    this.icon,
    this.label, {
    required this.glowColor,
    this.onTap,
    super.key,
  });

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF09221C), Color(0xFF02100C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: widget.glowColor.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.04),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.glowColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: widget.glowColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.glowColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: Alignment.center.y == 0 ? TextAlign.center : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
