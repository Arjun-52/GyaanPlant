import 'package:flutter/material.dart';
import 'roadmap_stage_model.dart';

class RoadmapStageCardWidget extends StatelessWidget {
  final RoadmapStage stage;
  final int index;
  final VoidCallback onTap;

  const RoadmapStageCardWidget({
    super.key,
    required this.stage,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: stage.isCompleted
              ? [const Color(0xFF00C853), const Color(0xFF00A651)]
              : [const Color(0xFF0D1F1A), const Color(0xFF12352B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: stage.isCompleted
                        ? const Color(0xFF00C853)
                        : Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stage.isCompleted
                          ? const Color(0xFF00C853)
                          : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: stage.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: stage.isCompleted
                                ? Colors.white
                                : const Color(0xFF12352B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: TextStyle(
                          color: stage.isCompleted
                              ? Colors.white
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.timeline,
                        style: TextStyle(
                          color: stage.isCompleted
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stage.description,
                        style: TextStyle(
                          color: stage.isCompleted
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!stage.isCompleted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
