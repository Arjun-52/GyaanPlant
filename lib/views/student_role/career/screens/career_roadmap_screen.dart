import 'package:flutter/material.dart';
import '../widgets/career_header_widget.dart';
import '../widgets/progress_section_widget.dart';
import '../widgets/roadmap_timeline_widget.dart';
import '../widgets/bottom_cta_widget.dart';
import '../widgets/roadmap_stage_model.dart';
import '../widgets/option_tile_widget.dart';

class CareerRoadmapScreen extends StatefulWidget {
  const CareerRoadmapScreen({super.key});

  @override
  State<CareerRoadmapScreen> createState() => _CareerRoadmapScreenState();
}

class _CareerRoadmapScreenState extends State<CareerRoadmapScreen> {
  // Mock data for demonstration
  final String careerRole = 'Data Analyst';
  final double matchPercentage = 87.0;
  final String estimatedTime = '90 Days';

  // Roadmap stages
  final List<RoadmapStage> roadmapStages = [
    RoadmapStage(
      id: 1,
      title: 'SQL & Excel Mastery',
      timeline: 'Weeks 1-2',
      isCompleted: true,
      description:
          'Master SQL queries, Excel functions, and data analysis fundamentals',
    ),
    RoadmapStage(
      id: 2,
      title: 'Python for Data Analysis',
      timeline: 'Weeks 3-4',
      isCompleted: true,
      description:
          'Learn Python programming with pandas, numpy, and data visualization',
    ),
    RoadmapStage(
      id: 3,
      title: 'Power BI Dashboards',
      timeline: 'Weeks 5-6',
      isCompleted: false,
      description:
          'Create interactive dashboards and business intelligence reports',
    ),
    RoadmapStage(
      id: 4,
      title: 'Mock Interviews',
      timeline: 'Weeks 7-8',
      isCompleted: false,
      description: 'Practice technical interviews and build confidence',
    ),
    RoadmapStage(
      id: 5,
      title: 'Resume & LinkedIn Optimization',
      timeline: 'Weeks 9-10',
      isCompleted: false,
      description:
          'Optimize resume and LinkedIn profile for data analyst roles',
    ),
    RoadmapStage(
      id: 6,
      title: 'Apply for Jobs',
      timeline: 'Weeks 11-12',
      isCompleted: false,
      description: 'Job search strategies and application techniques',
    ),
  ];

  int completedStages = 0;
  double progressPercentage = 0.0;

  void _calculateProgress() {
    completedStages = roadmapStages.where((stage) => stage.isCompleted).length;
    progressPercentage = (completedStages / roadmapStages.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    _calculateProgress();

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Career Roadmap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CareerHeaderWidget(
              careerRole: careerRole,
              matchPercentage: matchPercentage,
              estimatedTime: estimatedTime,
            ),
            const SizedBox(height: 24),
            ProgressSectionWidget(
              progressPercentage: progressPercentage,
              completedStages: completedStages,
              totalStages: roadmapStages.length,
            ),
            const SizedBox(height: 32),
            RoadmapTimelineWidget(
              roadmapStages: roadmapStages,
              onStageTap: _showStageDetails,
            ),
            const SizedBox(height: 32),
            BottomCTAWidget(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }

  void _showStageDetails(RoadmapStage stage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020B08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stage.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Start Learning',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContinueOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020B08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Continue Your Journey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            OptionTileWidget(
              icon: Icons.play_arrow,
              title: 'Resume Roadmap',
              subtitle: 'Continue where you left off',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            OptionTileWidget(
              icon: Icons.refresh,
              title: 'Reset Progress',
              subtitle: 'Start over with fresh goals',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
