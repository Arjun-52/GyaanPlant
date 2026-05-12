import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/ai_assistant_card.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/roadmap_timeline.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/daily_tasks_section.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/skill_analysis_card.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/job_readiness_section.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/mini_projects_section.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/mock_interview_section.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/widgets/floating_ai_chat.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/career_roadmap_viewmodel.dart';

class AICareerRoadmapScreen extends StatefulWidget {
  const AICareerRoadmapScreen({super.key});

  @override
  State<AICareerRoadmapScreen> createState() => _AICareerRoadmapScreenState();
}

class _AICareerRoadmapScreenState extends State<AICareerRoadmapScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressAnimationController.forward();
      }
    });
    
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareerRoadmapViewModel>().initializeRoadmap();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: Consumer<CareerRoadmapViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              // Header Section
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF061A14),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A2E1A).withOpacity(0.8),
                          const Color(0xFF061A14),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              // Target Role Title
                              Text(
                                'Your AI Generated ${viewModel.targetRole} Roadmap',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Stats Row
                              Row(
                                children: [
                                  // Match Percentage
                                  _buildStatCard(
                                    'Match',
                                    '${viewModel.matchPercentage}%',
                                    const Color(0xFF00C853),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Completion Time
                                  _buildStatCard(
                                    'Duration',
                                    viewModel.estimatedDuration,
                                    const Color(0xFF00E5FF),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Job Readiness
                                  _buildStatCard(
                                    'Readiness',
                                    '${viewModel.jobReadinessScore}%',
                                    const Color(0xFFFF6B35),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Progress Ring and Daily Streak
                              Row(
                                children: [
                                  // Animated Progress Ring
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: AnimatedBuilder(
                                      animation: _progressAnimation,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: ProgressRingPainter(
                                            progress: _progressAnimation.value * viewModel.overallProgress,
                                            strokeWidth: 6,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${(viewModel.overallProgress * 100).toInt()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 20),
                                  
                                  // Daily Streak
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Daily Streak',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department,
                                            color: Color(0xFFFF6B35),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${viewModel.dailyStreak} days',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content Sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // AI Assistant Card
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const AIAssistantCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Roadmap Timeline
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const RoadmapTimeline(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Daily Tasks Section
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const DailyTasksSection(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // AI Skill Analysis Card
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const SkillAnalysisCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Job Readiness Section
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const JobReadinessSection(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Mini Projects Section
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const MiniProjectsSection(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // AI Mock Interview Section
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: const MockInterviewSection(),
                    ),
                    
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ],
          );
        },
      ),
      
      // Floating AI Chat Button
      floatingActionButton: const FloatingAIChat(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Progress Ring Painter
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
