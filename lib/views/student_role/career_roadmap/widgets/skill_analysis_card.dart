import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/career_roadmap_viewmodel.dart';

class SkillAnalysisCard extends StatefulWidget {
  const SkillAnalysisCard({super.key});

  @override
  State<SkillAnalysisCard> createState() => _SkillAnalysisCardState();
}

class _SkillAnalysisCardState extends State<SkillAnalysisCard>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _chartAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareerRoadmapViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.1),
                const Color(0xFF061A14),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Skill Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // AI Insights
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Insights',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Based on your recent performance, I\'ve noticed significant improvement in your Excel skills. However, you should focus more on Python functions this week to maintain momentum.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Skills Grid
              Row(
                children: [
                  // Strengths
                  Expanded(
                    child: _buildSkillsSection(
                      'Strengths',
                      viewModel.strengths,
                      const Color(0xFF00C853),
                      Icons.trending_up,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Weaknesses
                  Expanded(
                    child: _buildSkillsSection(
                      'Areas to Improve',
                      viewModel.weaknesses,
                      const Color(0xFFFF6B35),
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Skill Chart
              _buildSkillChart(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillsSection(
    String title,
    List<Skill> skills,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Skills List
          ...skills.map((skill) => _buildSkillItem(skill, color)),
        ],
      ),
    );
  }

  Widget _buildSkillItem(Skill skill, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                skill.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${skill.level}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: skill.level / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChart(CareerRoadmapViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Skill Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animated Chart
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SkillChartPainter(
                    skills: [...viewModel.strengths, ...viewModel.weaknesses],
                    animation: _chartAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Skill Chart Painter
class SkillChartPainter extends CustomPainter {
  final List<Skill> skills;
  final double animation;

  SkillChartPainter({
    required this.skills,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 20.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);
    final barWidth = chartWidth / (skills.length * 2);
    
    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;
    
    // Y-axis
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );
    
    // X-axis
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );
    
    // Draw bars
    for (int i = 0; i < skills.length; i++) {
      final skill = skills[i];
      final barHeight = (skill.level / 100.0) * chartHeight * animation;
      final x = padding + (i * 2 * barWidth) + barWidth / 2;
      final y = size.height - padding - barHeight;
      
      // Determine color based on skill level
      Color barColor;
      if (skill.level >= 70) {
        barColor = const Color(0xFF00C853);
      } else if (skill.level >= 50) {
        barColor = const Color(0xFF00E5FF);
      } else {
        barColor = const Color(0xFFFF6B35);
      }
      
      // Draw bar
      final barPaint = Paint()
        ..color = barColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(barRect, barPaint);
      
      // Draw skill name (rotated)
      final textPainter = TextPainter(
        text: TextSpan(
          text: skill.name.length > 8 
              ? '${skill.name.substring(0, 8)}...'
              : skill.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Rotate text
      canvas.save();
      canvas.translate(x + barWidth / 2, size.height - padding + 15);
      canvas.rotate(-0.3); // Rotate slightly
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, 0),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
