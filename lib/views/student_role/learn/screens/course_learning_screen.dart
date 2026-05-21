import 'package:flutter/material.dart';
import 'package:gyaanplant/models/learning/player_models.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/curriculum_panel.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/lesson_info_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/navigation_controls_row.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/progress_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/video_player_section.dart';


// ============================================================================
// MAIN SCREEN WIDGET
// ============================================================================

class CourseLearningScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseLearningScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseLearningScreen> createState() => _CourseLearningScreenState();
}

class _CourseLearningScreenState extends State<CourseLearningScreen> {
  // Course State data
  late PlayerCourse _course;
  late List<PlayerLesson> _allLessons;
  
  // Navigation pointers
  int _currentLessonIndex = 0;
  bool _isCurriculumExpanded = true;

  @override
  void initState() {
    super.initState();
    // Load mock course details associated with this course title
    _course = PlayerCourse.mock(widget.courseTitle);
    
    // Extract flat list of lessons for easy linear navigation
    _allLessons = _course.sections.expand((sec) => sec.lessons).toList();

    // Start on the first uncompleted lesson, or default to the first lesson
    final firstUncompleted = _allLessons.indexWhere((lesson) => !lesson.isCompleted);
    if (firstUncompleted != -1) {
      _currentLessonIndex = firstUncompleted;
    }

    // TODO: Initial API triggers
    _fetchCourseDetails();
    _fetchLessons();
  }

  // ============================================================================
  // API INTEGRATION STUBS (TODOS)
  // ============================================================================

  /// TODO: Fetch complete course metadata from backend API.
  Future<void> _fetchCourseDetails() async {
    // print("API: fetchCourseDetails() trigger for course ${_course.id}");
  }

  /// TODO: Fetch lessons list & completion statuses from backend API.
  Future<void> _fetchLessons() async {
    // print("API: fetchLessons() trigger for course ${_course.id}");
  }

  /// TODO: Send completion progress update to backend API.
  Future<void> _updateProgress(String lessonId, bool isCompleted) async {
    // print("API: updateProgress() trigger for lesson $lessonId: completed=$isCompleted");
  }

  // ============================================================================
  // BUSINESS LOGIC PARADIGMS
  // ============================================================================

  PlayerLesson get _currentLesson => _allLessons[_currentLessonIndex];

  PlayerSection get _currentSection {
    // Identify which section owns the current lesson
    return _course.sections.firstWhere(
      (sec) => sec.lessons.any((lesson) => lesson.id == _currentLesson.id),
      orElse: () => _course.sections.first,
    );
  }

  int get _completedCount => _allLessons.where((l) => l.isCompleted).length;
  double get _completionPercent => _allLessons.isEmpty ? 0.0 : _completedCount / _allLessons.length;

  void _navigateToLesson(int index) {
    if (index >= 0 && index < _allLessons.length) {
      setState(() {
        _currentLessonIndex = index;
      });
    }
  }

  void _toggleLessonCompleted(PlayerLesson lesson) {
    setState(() {
      lesson.isCompleted = !lesson.isCompleted;
      _updateProgress(lesson.id, lesson.isCompleted);
    });
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    // Responsive padding calculation
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF031B15), // Matches GyaanPlant dark-green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08), // Dark glowing app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Lesson ${_currentLessonIndex + 1} of ${_allLessons.length} • ${(_completionPercent * 100).round()}% complete",
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. VIDEO PLAYER SECTION
              VideoPlayerSection(
                lesson: _currentLesson,
                onPlayTapped: () {
                  // Simulate play click
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Playing: ${_currentLesson.title}"),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF00C853),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. LESSON INFO CARD
              LessonInfoCard(
                section: _currentSection,
                lesson: _currentLesson,
                isCompleted: _currentLesson.isCompleted,
                onCheckboxChanged: (val) => _toggleLessonCompleted(_currentLesson),
              ),
              const SizedBox(height: 16),

              // 3. NAVIGATION CONTROLS (PREVIOUS / NEXT)
              NavigationControlsRow(
                currentIdx: _currentLessonIndex,
                maxCount: _allLessons.length,
                onPrevious: () => _navigateToLesson(_currentLessonIndex - 1),
                onNext: () => _navigateToLesson(_currentLessonIndex + 1),
              ),
              const SizedBox(height: 16),

              // 4. PROGRESS CARD
              ProgressCard(
                completedCount: _completedCount,
                totalCount: _allLessons.length,
                percent: _completionPercent,
              ),
              const SizedBox(height: 16),

              // 5. CURRICULUM PANEL
              CurriculumPanel(
                course: _course,
                selectedLessonId: _currentLesson.id,
                isExpanded: _isCurriculumExpanded,
                onToggleExpand: () {
                  setState(() {
                    _isCurriculumExpanded = !_isCurriculumExpanded;
                  });
                },
                onLessonClick: (lesson) {
                  final idx = _allLessons.indexOf(lesson);
                  if (idx != -1) {
                    _navigateToLesson(idx);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
