import 'package:flutter/material.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:provider/provider.dart';

import 'course_learning_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<LearningViewModel>().fetchMyCourses();
    });
  }

  String _getFallbackImageUrl(String title) {
    final t = title.toLowerCase();
    if (t.contains('rust')) {
      return 'https://img.icons8.com/color/144/rust.png';
    }
    if (t.contains('javascript') || t.contains('js')) {
      return 'https://img.icons8.com/color/144/javascript--v1.png';
    }
    if (t.contains('flutter') || t.contains('dart')) {
      return 'https://img.icons8.com/color/144/flutter.png';
    }
    if (t.contains('python')) {
      return 'https://img.icons8.com/color/144/python--v1.png';
    }
    if (t.contains('sql') || t.contains('database') || t.contains('db')) {
      return 'https://img.icons8.com/fluency/144/database.png';
    }
    if (t.contains('azure') || t.contains('cloud') || t.contains('aws')) {
      return 'https://img.icons8.com/color/144/azure-1.png';
    }
    if (t.contains('dsa') || t.contains('data structure') || t.contains('algorithm') || t.contains('coding')) {
      return 'https://img.icons8.com/fluency/144/code.png';
    }
    if (t.contains('aptitude') || t.contains('math') || t.contains('quant')) {
      return 'https://img.icons8.com/fluency/144/math.png';
    }
    if (t.contains('verbal') || t.contains('english') || t.contains('communication')) {
      return 'https://img.icons8.com/fluency/144/speech-bubble.png';
    }
    if (t.contains('hr') || t.contains('interview') || t.contains('career')) {
      return 'https://img.icons8.com/color/144/briefcase.png';
    }
    return 'https://img.icons8.com/fluency/144/education.png';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningViewModel>();
    final allEnrollments = vm.enrollments;

    // Filter enrollments based on search query and status filter selection
    final filteredEnrollments = allEnrollments.where((enrollment) {
      final title = enrollment.course.title.toLowerCase();
      final matchesSearch = title.contains(_searchQuery.toLowerCase());

      final progress = enrollment.progress ?? 0;
      bool matchesStatus = true;
      if (_selectedStatus == 'In Progress') {
        matchesStatus = progress > 0 && progress < 100;
      } else if (_selectedStatus == 'Completed') {
        matchesStatus = progress >= 100;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF020B08), // Signature dark green/black solid background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF00E676)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSearchFilterRow(),
                  const SizedBox(height: 24),
                  
                  // Total Enrolled Count Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Showing ${filteredEnrollments.length} enrolled courses",
                      style: TextStyle(
                        color: const Color(0xFF00E676).withValues(alpha: 0.65),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (filteredEnrollments.isEmpty)
                    _buildEmptyState()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredEnrollments.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(filteredEnrollments[index]);
                        },
                      ),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "My Learning Paths",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Track your upskilling progress and enrolled courses",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 3,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF061410),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                ),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search your courses...",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676), size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Dropdown
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF061410),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  dropdownColor: const Color(0xFF061410),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E676), size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                  items: <String>['All Status', 'In Progress', 'Completed']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Enrollment enrollment) {
    final course = enrollment.course;
    final progress = (enrollment.progress ?? 0).toDouble();
    final progressFraction = (progress / 100.0).clamp(0.0, 1.0);
    final hasThumbnail = course.thumbnail != null && course.thumbnail!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF09241E), // Sleek deep glass-teal
            Color(0xFF041411), // Deep black-green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail + Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  color: hasThumbnail ? const Color(0xFFD9D9D9) : Colors.white10,
                  padding: const EdgeInsets.all(6),
                  child: Image.network(
                    hasThumbnail ? course.thumbnail! : _getFallbackImageUrl(course.title),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      if (hasThumbnail) {
                        return Image.network(
                          _getFallbackImageUrl(course.title),
                          fit: BoxFit.contain,
                          errorBuilder: (context, e, st) {
                            return const Icon(
                              Icons.menu_book,
                              color: Colors.white38,
                              size: 28,
                            );
                          },
                        );
                      }
                      return const Icon(
                        Icons.menu_book,
                        color: Colors.white38,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${course.totalModules} modules",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Completion tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: progress >= 100
                            ? const Color(0xFF00C853).withValues(alpha: 0.1)
                            : const Color(0xFFFFA726).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: progress >= 100
                              ? const Color(0xFF00C853).withValues(alpha: 0.3)
                              : const Color(0xFFFFA726).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        progress >= 100 ? "COMPLETED" : "IN PROGRESS",
                        style: TextStyle(
                          color: progress >= 100
                              ? const Color(0xFF00C853)
                              : const Color(0xFFFFA726),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar + Percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      progress >= 100 ? const Color(0xFF00C853) : const Color(0xFF00E676),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${progress.toInt()}%",
                style: TextStyle(
                  color: progress >= 100 ? const Color(0xFF00C853) : const Color(0xFF00E676),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Resume / Continue Learning button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseLearningScreen(
                        courseId: course.id,
                        courseTitle: course.title,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: progress >= 100
                          ? [const Color(0xFF00C853).withValues(alpha: 0.2), const Color(0xFF00E676).withValues(alpha: 0.2)]
                          : [const Color(0xFF00E676), const Color(0xFF00C853)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: progress >= 100
                        ? Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      progress >= 100 ? "Review Course" : "Continue Learning →",
                      style: TextStyle(
                        color: progress >= 100 ? const Color(0xFF00E676) : const Color(0xFF031B15),
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF09241E),
                Color(0xFF041411),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 40,
                  color: Color(0xFF00E676),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Not enrolled in any courses yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start your journey today by browsing our catalog.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Switch to catalog tab (index 1) and pop screen
                    context.read<StudentTabController>().switchTab(1);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00E676),
                          Color(0xFF00C853),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Browse Catalog",
                      style: TextStyle(
                        color: Color(0xFF031B15),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
