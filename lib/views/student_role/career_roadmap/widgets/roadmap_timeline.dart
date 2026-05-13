import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/career_roadmap_viewmodel.dart';

class RoadmapTimeline extends StatelessWidget {
  const RoadmapTimeline({super.key});

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
                const Color(0xFF0A2E1A).withOpacity(0.8),
                const Color(0xFF061A14),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00C853).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withOpacity(0.1),
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
                    Icons.timeline,
                    color: Color(0xFF00C853),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Learning Roadmap',
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
                      color: const Color(0xFF00C853).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${viewModel.modules.length} Modules',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Timeline Modules
              ...viewModel.modules.asMap().entries.map((entry) {
                final index = entry.key;
                final module = entry.value;
                final isLast = index == viewModel.modules.length - 1;
                
                return _buildModuleCard(module, isLast);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModuleCard(RoadmapModule module, bool isLast) {
    return Column(
      children: [
        // Module Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: module.isCompleted
                ? const Color(0xFF00C853).withOpacity(0.1)
                : module.isLocked
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: module.isCompleted
                  ? const Color(0xFF00C853).withOpacity(0.5)
                  : module.isLocked
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Header
              Row(
                children: [
                  // Status Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: module.isCompleted
                          ? const Color(0xFF00C853)
                          : module.isLocked
                              ? Colors.grey.withOpacity(0.5)
                              : const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      module.isCompleted
                          ? Icons.check
                          : module.isLocked
                              ? Icons.lock
                              : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Module Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: TextStyle(
                            color: module.isLocked
                                ? Colors.grey.withOpacity(0.7)
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.description,
                          style: TextStyle(
                            color: module.isLocked
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(module.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      module.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(module.difficulty),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              if (!module.isLocked)
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${module.progress}%',
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: module.progress / 100.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: module.isCompleted
                                ? const Color(0xFF00C853)
                                : const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Module Stats
              Row(
                children: [
                  _buildStatItem(
                    Icons.schedule,
                    '${module.estimatedDays} days',
                    Colors.white70,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.star,
                    '${module.xpReward} XP',
                    const Color(0xFFFFD700),
                  ),
                  const Spacer(),
                  if (!module.isLocked)
                    _buildActionButton(module),
                ],
              ),
            ],
          ),
        ),
        
        // Timeline Connector
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 28, bottom: 16),
            height: 20,
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00C853).withOpacity(0.5),
                  const Color(0xFF00C853).withOpacity(0.1),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(RoadmapModule module) {
    final buttonText = module.progress > 0 ? 'Continue' : 'Start';
    final buttonColor = module.isCompleted
        ? const Color(0xFF00C853)
        : const Color(0xFF00E5FF);
    
    return GestureDetector(
      onTap: () {
        // Handle module start/continue
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: buttonColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: buttonColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return const Color(0xFF00C853);
      case 'Intermediate':
        return const Color(0xFF00E5FF);
      case 'Advanced':
        return const Color(0xFFFF6B35);
      default:
        return Colors.grey;
    }
  }
}
