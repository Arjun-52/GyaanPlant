import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/job_viewmodel.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_card.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_filter_row.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_header.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final AnimationController _pulseCtrl;

  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    print("🖥️ JobScreen initState() called");

    // Staggered Entrance Animation
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnims = List.generate(5, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(5, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });

    // Shimmer Pulse Controller
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      if (mounted) {
        print("🖥️ Calling fetchJobs() from JobScreen initState");
        context.read<JobViewModel>().fetchJobs().then((_) {
          if (mounted) {
            _staggerCtrl.forward(from: 0.0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBlock(height: 120, radius: 28),
          const SizedBox(height: 18),
          _skeletonBlock(height: 52, radius: 20),
          const SizedBox(height: 18),
          _skeletonBlock(height: 38, radius: 16),
          const SizedBox(height: 24),
          _skeletonBlock(height: 180, radius: 26),
          const SizedBox(height: 16),
          _skeletonBlock(height: 180, radius: 26),
        ],
      ),
    );
  }

  Widget _skeletonBlock({required double height, required double radius}) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                colors: [Color(0xFF0C241E), Color(0xFF02100C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.05),
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // Background ambient glowing gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF02120F), Color(0xFF020907)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0A00E676),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<JobViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return _buildSkeletonLoader();
                }

                if (!_staggerCtrl.isAnimating && _staggerCtrl.value == 0.0) {
                  _staggerCtrl.forward();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Job Header Card
                      FadeTransition(
                        opacity: _fadeAnims[0],
                        child: SlideTransition(
                          position: _slideAnims[0],
                          child: const JobHeader(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Search Bar
                      FadeTransition(
                        opacity: _fadeAnims[1],
                        child: SlideTransition(
                          position: _slideAnims[1],
                          child: const JobSearchBar(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3. Filter Pill Chips
                      FadeTransition(
                        opacity: _fadeAnims[2],
                        child: SlideTransition(
                          position: _slideAnims[2],
                          child: const JobFilterRow(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Job List / Empty State Card
                      FadeTransition(
                        opacity: _fadeAnims[3],
                        child: SlideTransition(
                          position: _slideAnims[3],
                          child: vm.filteredJobs.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0C2B22), Color(0xFF02110D)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF00E676).withOpacity(0.15),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: const Color(0x1A00E676),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF00E676).withOpacity(0.2),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00E676).withOpacity(0.1),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.work_outline_rounded,
                                          size: 32,
                                          color: Color(0xFF00E676),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "No Opportunities Available Yet",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "New AI-matched opportunities will appear here when available. Check back soon!",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: vm.filteredJobs.map((job) {
                                    return JobCard(
                                      title: job.role ?? 'No Role',
                                      company: job.companyName ?? 'Unknown Company',
                                      location: job.location ?? 'Not specified',
                                      salary: job.salary ?? 'Not specified',
                                      match: job.match,
                                      tags: job.skills ?? ['Job'],
                                      showBadge: job.isNew ?? false,
                                      badgeText: 'New',
                                      badgeColor: Colors.orange,
                                      logoColor: Colors.green,
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                    ],
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
