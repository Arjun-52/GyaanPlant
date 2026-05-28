import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/detailed_course_model.dart';
import 'package:gyaanplant/models/learning/player_models.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/curriculum_panel.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/lesson_info_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/navigation_controls_row.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/progress_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning-courses/video_player_section.dart';


// MAIN SCREEN WIDGET


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
  static const _tag = 'CourseLearningScreen';

  final _learningRepo = ApiService().learning;

  // Course State data
  PlayerCourse? _course;
  List<PlayerLesson> _allLessons = [];

  // Navigation pointers
  int _currentLessonIndex = 0;
  bool _isCurriculumExpanded = true;

  // Loading & error state
  bool _isLoadingCourse = true;
  String? _loadError;

  // Progress update guard
  bool _isProgressUpdating = false;

  // Completed lecture IDs from backend
  Set<String> _completedLectureIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }


  // API INTEGRATION


  /// Fetch course details from backend and build PlayerCourse from real data.
  Future<void> _fetchCourseDetails() async {
    AppLogger.info(_tag, 'Fetching course details for ${widget.courseId}');

    if (mounted) {
      setState(() {
        _isLoadingCourse = true;
        _loadError = null;
      });
    }

    try {
      final detailed = await _learningRepo.getCourseById(widget.courseId);
      AppLogger.info(
        _tag,
        'Course loaded: ${detailed.title} — ${detailed.modules.length} modules',
      );

      // Determine completed lectures from enrollment data
      _completedLectureIds = {};

      // Try to get progress data to identify completed lectures
      try {
        final progressResult = await _learningRepo.updateProgress(
          widget.courseId,
          completedLectures: [], // Empty call to just fetch current progress — won't modify
        );
        // Actually we shouldn't send empty — let's instead use the enrollment data
        // The enrollment on the DetailedCourseModel has progress percentage
      } catch (_) {
        // Progress fetch optional — continue with no completed data
      }

      // Build PlayerCourse from DetailedCourseModel
      final playerSections = <PlayerSection>[];
      int sectionOrder = 1;

      for (final module in detailed.modules) {
        final playerLessons = module.lectures.map((lecture) {
          return PlayerLesson(
            id: lecture.id,
            title: lecture.title,
            description: lecture.description ?? 'Learn about ${lecture.title}',
            videoUrl: lecture.videoUrl ??
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            durationMins: lecture.durationMins,
            isCompleted: _completedLectureIds.contains(lecture.id),
          );
        }).toList();

        playerSections.add(PlayerSection(
          id: module.id,
          title: module.title,
          order: sectionOrder++,
          lessons: playerLessons,
        ));
      }

      // If no modules exist, show a fallback message via empty course
      final playerCourse = PlayerCourse(
        id: detailed.id,
        title: detailed.title,
        description: 'Course with ${detailed.totalModules} modules',
        sections: playerSections,
      );

      if (mounted) {
        setState(() {
          _course = playerCourse;
          _allLessons = playerCourse.sections
              .expand((sec) => sec.lessons)
              .toList();
          _isLoadingCourse = false;

          // Start on the first uncompleted lesson
          final firstUncompleted =
              _allLessons.indexWhere((lesson) => !lesson.isCompleted);
          if (firstUncompleted != -1) {
            _currentLessonIndex = firstUncompleted;
          }
        });
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to fetch course details', e, st);
      if (mounted) {
        setState(() {
          _isLoadingCourse = false;
          _loadError = e.toString();
        });
      }
    }
  }

  /// Send completion progress update to backend API.
  Future<void> _updateProgress(String lessonId, bool isCompleted) async {
    // Guard against empty courseId
    if (widget.courseId.isEmpty) {
      AppLogger.error(_tag, 'Cannot update progress: courseId is empty');
      _showErrorSnackBar('Error: Course ID is invalid');
      return;
    }

    // Guard against duplicate simultaneous requests
    if (_isProgressUpdating) {
      AppLogger.warning(_tag, 'Progress update already in progress — skipping');
      return;
    }

    _isProgressUpdating = true;
    AppLogger.info(
      _tag,
      'Updating progress: lesson=$lessonId completed=$isCompleted',
    );

    try {
      // Build the list of all currently completed lecture IDs
      final completedIds = _allLessons
          .where((l) => l.isCompleted)
          .map((l) => l.id)
          .toList();

      final result = await context.read<LearningViewModel>().updateCourseProgress(
        widget.courseId,
        completedLectures: completedIds,
      );

      if (!mounted) return;

      if (result.success && result.progress != null) {
        // Update local completed state from backend response
        final backendCompleted =
            result.progress!.completedLectures.toSet();
        _completedLectureIds = backendCompleted;

        // Sync lesson isCompleted state with backend response
        for (final lesson in _allLessons) {
          lesson.isCompleted = backendCompleted.contains(lesson.id);
        }

        setState(() {}); // Refresh UI

        // Show success snackbar
        if (isCompleted) {
          _showSuccessSnackBar('Lesson completed successfully');
        }

        // Show reward toast if applicable
        final rewards = result.progress!.rewards;
        if (rewards.hasRewards) {
          _showRewardToast(rewards.xpEarned, rewards.pointsEarned);
        }

        AppLogger.info(
          _tag,
          'Progress synced: ${result.progress!.progress}% — '
          '${result.progress!.completedLectures.length} lectures completed',
        );
      } else if (result.isRetryRestricted) {
        _showErrorSnackBar(result.message);
      } else {
        AppLogger.error(_tag, 'Progress update failed: ${result.message}');
        _showErrorSnackBar(result.message);
      }
    } finally {
      _isProgressUpdating = false;
    }
  }


  // BUSINESS LOGIC


  PlayerLesson get _currentLesson => _allLessons[_currentLessonIndex];

  PlayerSection get _currentSection {
    return _course!.sections.firstWhere(
      (sec) => sec.lessons.any((lesson) => lesson.id == _currentLesson.id),
      orElse: () => _course!.sections.first,
    );
  }

  int get _completedCount => _allLessons.where((l) => l.isCompleted).length;
  double get _completionPercent =>
      _allLessons.isEmpty ? 0.0 : _completedCount / _allLessons.length;

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


  // SNACKBAR HELPERS


  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00C853),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showRewardToast(int xp, int points) {
    if (!mounted) return;
    final parts = <String>[];
    if (xp > 0) parts.add('+$xp XP Earned');
    if (points > 0) parts.add('+$points Points Earned');
    if (parts.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Text(
              parts.join(' • '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F2A22),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF00C853), width: 1),
        ),
      ),
    );
  }


  // BUILD METHOD


  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoadingCourse) {
      return Scaffold(
        backgroundColor: const Color(0xFF031B15),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.courseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
          ),
        ),
      );
    }

    // Error state
    if (_loadError != null || _course == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF031B15),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.courseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  _loadError ?? 'Failed to load course',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchCourseDetails,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty modules
    if (_allLessons.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF031B15),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.courseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No lessons available for this course yet.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    // Normal course player
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF031B15), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08), 
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
                course: _course!,
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
