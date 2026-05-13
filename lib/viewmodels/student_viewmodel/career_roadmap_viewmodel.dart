import 'package:flutter/foundation.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';

class CareerRoadmapViewModel extends ChangeNotifier {
  static const _tag = 'CareerRoadmapViewModel';

  // User Profile Data
  String _targetRole = 'Data Analyst';
  int _matchPercentage = 87;
  String _estimatedDuration = '90 days';
  int _jobReadinessScore = 75;
  double _overallProgress = 0.65;
  int _dailyStreak = 12;

  // Getters
  String get targetRole => _targetRole;
  int get matchPercentage => _matchPercentage;
  String get estimatedDuration => _estimatedDuration;
  int get jobReadinessScore => _jobReadinessScore;
  double get overallProgress => _overallProgress;
  int get dailyStreak => _dailyStreak;

  // Roadmap Modules
  List<RoadmapModule> _modules = [
    RoadmapModule(
      id: '1',
      title: 'SQL Fundamentals',
      description: 'Master the basics of SQL queries and database operations',
      progress: 100,
      estimatedDays: 15,
      difficulty: 'Beginner',
      xpReward: 500,
      isCompleted: true,
      isLocked: false,
    ),
    RoadmapModule(
      id: '2',
      title: 'Excel Mastery',
      description: 'Advanced Excel functions, pivot tables, and data visualization',
      progress: 100,
      estimatedDays: 20,
      difficulty: 'Intermediate',
      xpReward: 750,
      isCompleted: true,
      isLocked: false,
    ),
    RoadmapModule(
      id: '3',
      title: 'Python for Data Analysis',
      description: 'Python programming with pandas, numpy, and matplotlib',
      progress: 60,
      estimatedDays: 25,
      difficulty: 'Intermediate',
      xpReward: 1000,
      isCompleted: false,
      isLocked: false,
    ),
    RoadmapModule(
      id: '4',
      title: 'Power BI Dashboards',
      description: 'Create interactive dashboards and business intelligence reports',
      progress: 0,
      estimatedDays: 20,
      difficulty: 'Intermediate',
      xpReward: 800,
      isCompleted: false,
      isLocked: false,
    ),
    RoadmapModule(
      id: '5',
      title: 'Portfolio Projects',
      description: 'Build real-world data analysis projects for your portfolio',
      progress: 0,
      estimatedDays: 30,
      difficulty: 'Advanced',
      xpReward: 1500,
      isCompleted: false,
      isLocked: true,
    ),
    RoadmapModule(
      id: '6',
      title: 'Mock Interviews',
      description: 'Practice technical interviews with AI-powered feedback',
      progress: 0,
      estimatedDays: 10,
      difficulty: 'Advanced',
      xpReward: 600,
      isCompleted: false,
      isLocked: true,
    ),
    RoadmapModule(
      id: '7',
      title: 'Resume Optimization',
      description: 'Craft the perfect data analyst resume and LinkedIn profile',
      progress: 0,
      estimatedDays: 5,
      difficulty: 'Beginner',
      xpReward: 300,
      isCompleted: false,
      isLocked: true,
    ),
  ];

  // Daily Tasks
  List<DailyTask> _dailyTasks = [
    DailyTask(
      id: '1',
      title: 'Learn SQL JOINS',
      description: 'Master inner, outer, left, and right joins',
      xpReward: 50,
      isCompleted: true,
    ),
    DailyTask(
      id: '2',
      title: 'Solve 10 practice questions',
      description: 'Complete SQL coding challenges',
      xpReward: 75,
      isCompleted: true,
    ),
    DailyTask(
      id: '3',
      title: 'Build mini dashboard',
      description: 'Create a Power BI dashboard with sample data',
      xpReward: 100,
      isCompleted: false,
    ),
  ];

  // Skill Analysis
  List<Skill> _strengths = [
    Skill(name: 'Excel', level: 85),
    Skill(name: 'Data Visualization', level: 78),
  ];

  List<Skill> _weaknesses = [
    Skill(name: 'SQL Joins', level: 45),
    Skill(name: 'Python Functions', level: 52),
  ];

  // Job Market Data
  List<String> _hiringCompanies = ['TCS', 'Infosys', 'Amazon', 'Flipkart'];
  String _estimatedSalary = '6-12 LPA';
  int _skillsRemaining = 3;

  // Mini Projects
  List<MiniProject> _miniProjects = [
    MiniProject(
      id: '1',
      title: 'Sales Dashboard',
      description: 'Interactive sales analytics dashboard',
      difficulty: 'Intermediate',
      technologies: ['Power BI', 'SQL', 'Excel'],
      resumeImpact: 'High',
    ),
    MiniProject(
      id: '2',
      title: 'Netflix Data Analysis',
      description: 'Analyze Netflix viewing patterns and trends',
      difficulty: 'Advanced',
      technologies: ['Python', 'Pandas', 'Matplotlib'],
      resumeImpact: 'Very High',
    ),
    MiniProject(
      id: '3',
      title: 'IPL Statistics Analyzer',
      description: 'Cricket match data analysis and predictions',
      difficulty: 'Intermediate',
      technologies: ['Python', 'SQL', 'Power BI'],
      resumeImpact: 'High',
    ),
  ];

  // Getters
  List<RoadmapModule> get modules => _modules;
  List<DailyTask> get dailyTasks => _dailyTasks;
  List<Skill> get strengths => _strengths;
  List<Skill> get weaknesses => _weaknesses;
  List<String> get hiringCompanies => _hiringCompanies;
  String get estimatedSalary => _estimatedSalary;
  int get skillsRemaining => _skillsRemaining;
  List<MiniProject> get miniProjects => _miniProjects;

  // AI Assistant Message
  String get aiMessage => _generateAIMessage();

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initializeRoadmap() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call to get personalized roadmap
      await Future.delayed(const Duration(seconds: 1));
      
      // Update based on user profile (mock data for now)
      _updatePersonalizedRoadmap();
      
      AppLogger.info(_tag, 'Career roadmap initialized successfully');
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to initialize roadmap', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updatePersonalizedRoadmap() {
    // Mock personalization logic
    // In real app, this would analyze user profile, skills, and goals
    _matchPercentage = 87;
    _jobReadinessScore = 75;
    _overallProgress = 0.65;
    _dailyStreak = 12;
  }

  String _generateAIMessage() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    
    return "$greeting! Based on your profile and completed skills, I've designed a personalized 90-day roadmap to make you job ready. Your SQL fundamentals are strong, and you're making great progress in Python. Let's focus on Power BI next week to boost your data visualization skills.";
  }

  // Actions
  Future<void> startModule(String moduleId) async {
    try {
      final module = _modules.firstWhere((m) => m.id == moduleId);
      if (!module.isLocked) {
        // Navigate to module content
        AppLogger.info(_tag, 'Starting module: ${module.title}');
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to start module: $moduleId', e);
    }
  }

  Future<void> completeDailyTask(String taskId) async {
    try {
      final task = _dailyTasks.firstWhere((t) => t.id == taskId);
      if (!task.isCompleted) {
        task.isCompleted = true;
        
        // Update user XP and progress
        _updateProgress(task.xpReward);
        
        AppLogger.info(_tag, 'Completed daily task: ${task.title}');
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to complete task: $taskId', e);
    }
  }

  void _updateProgress(int xpGained) {
    // Update overall progress based on XP
    _overallProgress = (_overallProgress + (xpGained / 10000)).clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> startMockInterview() async {
    try {
      AppLogger.info(_tag, 'Starting AI mock interview');
      // Navigate to mock interview screen
    } catch (e) {
      AppLogger.error(_tag, 'Failed to start mock interview', e);
    }
  }

  Future<void> startMiniProject(String projectId) async {
    try {
      final project = _miniProjects.firstWhere((p) => p.id == projectId);
      AppLogger.info(_tag, 'Starting mini project: ${project.title}');
      // Navigate to project screen
    } catch (e) {
      AppLogger.error(_tag, 'Failed to start project: $projectId', e);
    }
  }
}

// Data Models
class RoadmapModule {
  final String id;
  final String title;
  final String description;
  final int progress;
  final int estimatedDays;
  final String difficulty;
  final int xpReward;
  final bool isCompleted;
  final bool isLocked;

  RoadmapModule({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.estimatedDays,
    required this.difficulty,
    required this.xpReward,
    required this.isCompleted,
    required this.isLocked,
  });
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.isCompleted,
  });
}

class Skill {
  final String name;
  final int level;

  Skill({
    required this.name,
    required this.level,
  });
}

class MiniProject {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> technologies;
  final String resumeImpact;

  MiniProject({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.technologies,
    required this.resumeImpact,
  });
}
