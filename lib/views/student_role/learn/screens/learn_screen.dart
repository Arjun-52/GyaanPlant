import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course_progress_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/filter_chips.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning_header.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/search_input_field.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCourses();
      }
    });
  }

  void _loadCourses() async {
    if (mounted) {
      await context.read<LearningViewModel>().fetchCourses();
      if (mounted) {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // ── BACKGROUND GLOW LAYER ─────────────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.06),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B0FF).withValues(alpha: 0.04),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // ── MAIN CONTENT LAYER ─────────────────────────────────────────────
          Consumer<LearningViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const _LearningScreenLoader();
              }

              if (vm.errorMessage != null) {
                return _buildErrorState(vm.errorMessage!);
              }

              final availableCourses = vm.availableFilteredCourses;

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LearningHeader(),
                          
                          // Search Box
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SearchInputField(
                              onChanged: (query) {
                                vm.updateSearchQuery(query);
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          
                          // Category Selector
                          const FilterChips(),
                          const SizedBox(height: 22),

                          // Courses Heading
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Available Modules (${availableCourses.length})",
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Gilroy-Semibold',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8fa59e),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Courses List
                          if (availableCourses.isEmpty)
                            _buildEmptyState(vm)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: List.generate(availableCourses.length, (index) {
                                  final course = availableCourses[index];
                                  
                                  // Staggered animated entrance for each card
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, val, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1.0 - val)),
                                        child: Opacity(
                                          opacity: val,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: CourseProgressCard(
                                      courseId: course.id,
                                      title: course.title,
                                      subtitle: '${course.totalModules} comprehensive modules',
                                      percentText: '0%',
                                      progressCount: '0/${course.totalModules}',
                                      progress: 0.0,
                                      progressColor: const Color(0xFF00E676),
                                      tag: 'New',
                                      tagColor: const Color(0xFF00E676),
                                      isEnrolled: false,
                                      thumbnail: course.thumbnail,
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Spacer to allow scrolling past the floating bottom CTA bar
                          const SizedBox(height: 130),
                        ],
                      ),
                    ),

                    // ── FLOATING GLASS MY COURSES BAR ──────────────────────────
                    if (availableCourses.isNotEmpty || vm.searchQuery.isNotEmpty || vm.selectedCategory != 'All')
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF020B08).withValues(alpha: 0.8),
                                const Color(0xFF020B08),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Feedback.forTap(context);
                                      context.push('/my-courses');
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00E676).withValues(alpha: 0.25),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: const Color(0xFF00E676),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.local_library_rounded,
                                            color: Color(0xFF020B08),
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "My Enrolled Courses",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Gilroy-Semibold',
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF020B08),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── ERROR STATE WIDGET ──────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF5252),
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Gilroy-Semibold',
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadCourses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry Network Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATE WIDGET ──────────────────────────────────────────────────
  Widget _buildEmptyState(LearningViewModel vm) {
    final hasSearch = vm.searchQuery.isNotEmpty;
    final hasFilter = vm.selectedCategory != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF061411).withValues(alpha: 0.6),
            border: Border.all(
              color: const Color(0xFF163E33).withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.05),
                ),
                child: const Icon(
                  Icons.layers_clear_rounded,
                  size: 48,
                  color: Color(0xFF00E676),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No Available Pathway Modules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Gilroy-Semibold',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSearch || hasFilter
                    ? 'Adjust filters or clear your search terms to reveal available modules.'
                    : 'Explore my courses or database connections to sync additional files.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Gilroy-Semibold',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (hasSearch || hasFilter)
                OutlinedButton(
                  onPressed: () {
                    vm.updateSearchQuery('');
                    vm.updateSelectedCategory('All');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E676),
                    side: const BorderSide(color: Color(0xFF00E676), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  ),
                  child: const Text(
                    'Reset All Parameters',
                    style: TextStyle(
                      fontFamily: 'Gilroy-Semibold',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    Feedback.forTap(context);
                    context.push('/my-courses');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E676),
                    side: const BorderSide(color: Color(0xFF00E676), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  ),
                  child: const Text(
                    'View My Courses',
                    style: TextStyle(
                      fontFamily: 'Gilroy-Semibold',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

// ── CUSTOM SHIMMER SKELETON LOADING WIDGET ────────────────────────────────
class _LearningScreenLoader extends StatefulWidget {
  const _LearningScreenLoader();

  @override
  State<_LearningScreenLoader> createState() => _LearningScreenLoaderState();
}

class _LearningScreenLoaderState extends State<_LearningScreenLoader> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final shimmerColor = const Color(0xFF163E33).withValues(alpha: _pulseAnimation.value);
        final darkBlock = const Color(0xFF05120E);

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Shimmer
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 32,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 200,
                            height: 12,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: darkBlock,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: shimmerColor, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector Shimmer
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) => Container(
                    width: index == 0 ? 60 : (index == 1 ? 100 : 80),
                    height: 46,
                    decoration: BoxDecoration(
                      color: darkBlock,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: shimmerColor, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Subheading Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cards Shimmer List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: darkBlock,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: shimmerColor, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: shimmerColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 100,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: shimmerColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: shimmerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

