import 'package:flutter/material.dart';
import 'roadmap_stage_model.dart';
import 'roadmap_stage_card_widget.dart';

class RoadmapTimelineWidget extends StatelessWidget {
  final List<RoadmapStage> roadmapStages;
  final Function(RoadmapStage) onStageTap;

  const RoadmapTimelineWidget({
    super.key,
    required this.roadmapStages,
    required this.onStageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: roadmapStages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          return RoadmapStageCardWidget(
            stage: stage,
            index: index,
            onTap: () => onStageTap(stage),
          );
        }).toList(),
      ),
    );
  }
}
