import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/add_student_screen.dart';
import 'package:gyaanplant/views/tpo_role/student/widgets/student_card.dart';
import 'package:provider/provider.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> with TickerProviderStateMixin {
  AnimationController? _entranceCtrl;
  List<Animation<double>> _fadeAnims = [];
  List<Animation<Offset>> _slideAnims = [];

  @override
  void initState() {
    super.initState();
    print('🎯 StudentScreen.initState() called');

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnims = List.generate(5, (index) {
      final double start = index * 0.1;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl!,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(5, (index) {
      final double start = index * 0.1;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl!,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });

    Future.microtask(() {
      if (mounted) {
        print('🔔 Calling StudentViewModel.initialize() from initState');
        context.read<StudentViewModel>().initialize().then((_) {
          if (mounted) {
            _entranceCtrl?.forward(from: 0.0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // Background glows
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
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0800FFA3),
                ),
              ),
            ),
          ),

          Consumer<StudentViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading && viewModel.students.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFA3)),
                );
              }

              // Re-trigger stagger on loaded list
              if (_entranceCtrl != null && !_entranceCtrl!.isAnimating && _entranceCtrl!.value == 0.0) {
                _entranceCtrl!.forward();
              }

              final filteredStudents = viewModel.filteredStudents;

              return RefreshIndicator(
                onRefresh: () async {
                  print('🔄 Refresh triggered');
                  await viewModel.refreshStudents();
                  if (mounted) {
                    _entranceCtrl?.forward(from: 0.0);
                  }
                },
                color: const Color(0xFF00FFA3),
                backgroundColor: const Color(0xFF020B08),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. HEADER SECTION
                        FadeTransition(
                          opacity: _fadeAnims[0],
                          child: SlideTransition(
                            position: _slideAnims[0],
                            child: _buildHeader(viewModel),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 2. SEARCH BAR
                        FadeTransition(
                          opacity: _fadeAnims[1],
                          child: SlideTransition(
                            position: _slideAnims[1],
                            child: _buildSearchBar(viewModel),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. FILTER PILLS
                        FadeTransition(
                          opacity: _fadeAnims[2],
                          child: SlideTransition(
                            position: _slideAnims[2],
                            child: _buildFilters(viewModel),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. MAIN CANDIDATES LIST
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnims[3],
                            child: SlideTransition(
                              position: _slideAnims[3],
                              child: _buildListContent(viewModel, filteredStudents),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(StudentViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Students',
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '${viewModel.students.length}',
                    style: const TextStyle(
                      color: Color(0xFF00FFA3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Track readiness, performance, and placement progress.',
              style: TextStyle(
                fontFamily: 'Gilroy-Medium',
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
        // Add Student CTA
        GestureDetector(
          onTap: () {
            final studentVm = context.read<StudentViewModel>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: studentVm,
                  child: const AddStudentScreen(),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.black, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(StudentViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
      ),
      child: TextField(
        onChanged: viewModel.setSearch,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Search by name, roll number...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.35),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00FFA3), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(StudentViewModel viewModel) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip('All', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('MNC Ready', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('Average', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('At Risk', viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StudentViewModel viewModel) {
    final isSelected = viewModel.selectedFilter == label;
    return GestureDetector(
      onTap: () => viewModel.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FFA3) : const Color(0xFF0C241B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00FFA3) : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent(StudentViewModel viewModel, List<dynamic> filteredStudents) {
    if (filteredStudents.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: filteredStudents.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: StudentCard(student: filteredStudents[index]),
              );
            },
          ),
        ),
        // Information badge footer
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0C241B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          child: Text(
            "Showing ${filteredStudents.length} of ${viewModel.students.length} students",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0C241B).withValues(alpha: 0.15),
          border: Border.all(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                color: Color(0xFF00FFA3),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎓 No Students Found',
              style: TextStyle(
                fontFamily: 'Gilroy-Bold',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Students will appear here once added.',
              style: TextStyle(
                fontFamily: 'Gilroy-Medium',
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
