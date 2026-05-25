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

class _StudentScreenState extends State<StudentScreen> {
  @override
  void initState() {
    super.initState();
    print('🎯 StudentScreen.initState() called');
    Future.microtask(() {
      if (mounted) {
        print('🔔 Calling StudentViewModel.initialize() from initState');
        context.read<StudentViewModel>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: Consumer<StudentViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: () {
              print('🔄 Refresh triggered');
              return viewModel.refreshStudents();
            },
            color: Colors.green,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Students',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00C853).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_rounded, color: Colors.black, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Add Student',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      onChanged: viewModel.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search by name, roll number...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white38,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F2A22),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.green.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('All', viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip('MNC Ready', viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip('At Risk', viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip('Average', viewModel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(child: _buildContent(viewModel)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, StudentViewModel viewModel) {
    final isSelected = viewModel.selectedFilter == label;
    return GestureDetector(
      onTap: () => viewModel.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(StudentViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Loading students...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load students',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('🔄 Retry button pressed');
                viewModel.refreshStudents();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasData) {
      return _buildEmptyState('No students found');
    }

    final filteredStudents = viewModel.filteredStudents;
    if (filteredStudents.isEmpty) {
      return _buildEmptyState('No students match your search');
    }

    print('📱 Displaying ${filteredStudents.length} students');
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: filteredStudents.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudentCard(student: filteredStudents[index]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              "Showing ${filteredStudents.length} of ${viewModel.students.length} students",
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF00C853),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query or filters.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
