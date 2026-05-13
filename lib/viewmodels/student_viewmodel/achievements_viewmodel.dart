import 'package:flutter/foundation.dart';

/// Model for achievement data
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String category;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.category,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🏆',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      category: json['category']?.toString() ?? 'general',
    );
  }
}

/// ViewModel for managing achievements
class AchievementsViewModel extends ChangeNotifier {
  // State variables
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAchievements => _achievements.isNotEmpty;
  bool get hasError => _errorMessage != null;
  
  // Get unlocked achievements
  List<AchievementModel> get unlockedAchievements => 
      _achievements.where((achievement) => achievement.isUnlocked).toList();
  
  // Get locked achievements
  List<AchievementModel> get lockedAchievements => 
      _achievements.where((achievement) => !achievement.isUnlocked).toList();

  /// Initialize the ViewModel and fetch achievements
  Future<void> initialize() async {
    await fetchAchievements();
  }

  /// Fetch achievements from API (placeholder for future API integration)
  Future<void> fetchAchievements() async {
    print("🏆 AchievementsViewModel: Fetching achievements...");
    
    _setLoading(true);
    _clearError();

    try {
      // TODO: Replace with actual API call when achievements API is ready
      // final response = await ApiClient.getAchievements();
      // _achievements = response.data.map((json) => AchievementModel.fromJson(json)).toList();
      
      // For now, keep empty to show empty state
      _achievements = [];
      
      print("✅ AchievementsViewModel: Fetched ${_achievements.length} achievements");
      
    } catch (e) {
      print("❌ AchievementsViewModel: Error fetching achievements: $e");
      _setError('Failed to load achievements: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Retry fetching achievements
  Future<void> retry() async {
    await fetchAchievements();
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("🏆 AchievementsViewModel: Disposed");
    super.dispose();
  }
}
