import 'dart:ui';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      backgroundColor: const Color(0xFF030705), // Futuristic deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C241B).withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFA3), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── BACKGROUND GLOW ORBS ─────────────────────────────────────────
          _GlowingOrb(
            top: -50,
            left: -50,
            size: screenWidth * 0.6,
            color: const Color(0xFF00FFA3),
          ),
          _GlowingOrb(
            top: screenHeight * 0.4,
            left: screenWidth * 0.5,
            size: screenWidth * 0.7,
            color: const Color(0xFF00FFA3),
          ),
          _GlowingOrb(
            top: screenHeight * 0.75,
            left: -100,
            size: screenWidth * 0.8,
            color: const Color(0xFF0F3B2E),
          ),

          // ── MAIN CONTENT ──────────────────────────────────────────────────
          vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF00FFA3)),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated entrance header
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Transform.translate(
                            offset: Offset(0, -20 * (1.0 - val)),
                            child: Opacity(opacity: val, child: child),
                          );
                        },
                        child: _buildHeader(),
                      ),

                      // Animated entrance search
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * (1.0 - val)),
                            child: Opacity(opacity: val, child: child),
                          );
                        },
                        child: _buildSearchFilterRow(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Total Enrolled Count Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, child) {
                            return Opacity(opacity: val, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _PulsingDot(),
                                const SizedBox(width: 8),
                                Text(
                                  "Showing ${filteredEnrollments.length} enrolled courses",
                                  style: const TextStyle(
                                    color: Color(0xFF00FFA3),
                                    fontSize: 12.5,
                                    fontFamily: 'Gilroy-Semibold',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

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
                              // Staggered loading animations
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 400 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1.0 - val)),
                                    child: Opacity(opacity: val, child: child),
                                  );
                                },
                                child: _buildCourseCard(filteredEnrollments[index]),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3B2E).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF00FFA3), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                "My Learning Paths",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gilroy-Bold',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Track your upskilling progress and enrolled courses in real time.",
            style: TextStyle(
              color: Color(0xFF8FA59E),
              fontFamily: 'Gilroy-Semibold',
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    final searchField = Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Gilroy-Medium'),
        decoration: const InputDecoration(
          hintText: "Search your courses...",
          hintStyle: TextStyle(color: Color(0xFF4A6B5D), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Color(0xFF00FFA3), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );

    final filterDropdown = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedStatus,
          dropdownColor: const Color(0xFF030D09),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FFA3), size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Gilroy-Semibold'),
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
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isMobile
          ? Column(
              children: [
                searchField,
                const SizedBox(height: 10),
                filterDropdown,
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: searchField,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: filterDropdown,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF061411).withValues(alpha: 0.8),
                  const Color(0xFF0B211B).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail + Title Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glassmorphic Image Container
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF122C25).withValues(alpha: 0.5),
                        border: Border.all(
                          color: const Color(0xFF1F5A4A).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        hasThumbnail ? course.thumbnail! : _getFallbackImageUrl(course.title),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF00FFA3),
                            size: 28,
                          );
                        },
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
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${course.totalModules} comprehensive modules",
                            style: const TextStyle(
                              color: Color(0xFF8FA59E),
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Premium Status Pill
                          _buildStatusPill(progress),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Progress Bar Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          progress >= 100 ? "Module Completed!" : "Pathway Progress",
                          style: TextStyle(
                            color: progress >= 100 ? const Color(0xFF00FFA3) : const Color(0xFF8FA59E),
                            fontFamily: 'Gilroy-Semibold',
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                        Text(
                          "${progress.toInt()}%",
                          style: TextStyle(
                            color: progress >= 100 ? const Color(0xFF00FFA3) : const Color(0xFF00B0FF),
                            fontFamily: 'Gilroy-Bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 6,
                        width: double.infinity,
                        color: Colors.white10,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressFraction,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00FFA3), Color(0xFF00B0FF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00FFA3).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Continuing Button
                _buildContinueLearningButton(enrollment, progress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(double progress) {
    final isCompleted = progress >= 100;
    final hasStarted = progress > 0;

    final Color bgColor = isCompleted 
        ? const Color(0xFF00FFA3).withValues(alpha: 0.1) 
        : (hasStarted ? const Color(0xFFFFA726).withValues(alpha: 0.1) : const Color(0xFF00B0FF).withValues(alpha: 0.1));
    
    final Color borderAndTextColor = isCompleted 
        ? const Color(0xFF00FFA3) 
        : (hasStarted ? const Color(0xFFFFA726) : const Color(0xFF00B0FF));

    final String label = isCompleted 
        ? "COMPLETED" 
        : (hasStarted ? "IN PROGRESS" : "NOT STARTED");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderAndTextColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: borderAndTextColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: borderAndTextColor,
              fontFamily: 'Gilroy-Bold',
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningButton(Enrollment enrollment, double progress) {
    final course = enrollment.course;
    final isCompleted = progress >= 100;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: !isCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Feedback.forTap(context);
            final courseId = course.id;
            print('Enrollment JSON: $enrollment');
            print('Course object: ${enrollment.course}');
            print('Extracted courseId: $courseId');
            
            if (courseId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Course details not found: ID is empty.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF00FFA3).withValues(alpha: 0.15),
                        const Color(0xFF00C853).withValues(alpha: 0.15),
                      ],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF00FFA3), Color(0xFF00C853)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00FFA3).withValues(alpha: isCompleted ? 0.3 : 0.8),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                isCompleted ? "Review Course" : "Continue Learning",
                style: TextStyle(
                  color: isCompleted ? const Color(0xFF00FFA3) : const Color(0xFF031B15),
                  fontFamily: 'Gilroy-Bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
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
            gradient: LinearGradient(
              colors: [
                const Color(0xFF061411).withValues(alpha: 0.8),
                const Color(0xFF0B211B).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  "📚",
                  style: TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "No Learning Paths Yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gilroy-Bold',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enroll in a course to start your learning journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8FA59E),
                  fontFamily: 'Gilroy-Medium',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<StudentTabController>().switchTab(1);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FFA3),
                          Color(0xFF00C853),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Browse Catalog",
                      style: TextStyle(
                        color: Color(0xFF031B15),
                        fontFamily: 'Gilroy-Bold',
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

// ── FLOATING ANIMATED ORB WIDGET ──────────────────────────────────────────
class _GlowingOrb extends StatefulWidget {
  final double top;
  final double left;
  final double size;
  final Color color;

  const _GlowingOrb({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
  });

  @override
  State<_GlowingOrb> createState() => _GlowingOrbState();
}

class _GlowingOrbState extends State<_GlowingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final currentSize = widget.size * _animation.value;
          return Container(
            width: currentSize,
            height: currentSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.06 * _animation.value),
                  blurRadius: currentSize * 0.6,
                  spreadRadius: currentSize * 0.15,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── BREATHING PULSING BADGE DOT ───────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFF00FFA3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.6 * _animation.value),
                blurRadius: 6 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
