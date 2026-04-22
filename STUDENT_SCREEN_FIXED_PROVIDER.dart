import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
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
    // Initialize ViewModel once when screen is created
    Future.microtask(() {
      if (mounted) {
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
            onRefresh: viewModel.refreshStudents,
            color: Colors.green,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    const Text(
                      "Students",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// SEARCH BAR
                    TextField(
                      onChanged: viewModel.setSearch,
                      decoration: InputDecoration(
                        hintText: "Search students...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    /// FILTER CHIPS
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip("All", viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip("MNC Ready", viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip("At Risk", viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip("Average", viewModel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// CONTENT
                    Expanded(
                      child: _buildContent(viewModel),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const TpoBottomNav(currentIndex: 1),
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
    // LOADING STATE
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              "Loading students...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // ERROR STATE
    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Failed to load students",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? "Unknown error",
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refreshStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    // EMPTY STATE
    if (!viewModel.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "No students found",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // SUCCESS STATE WITH DATA
    final filteredStudents = viewModel.filteredStudents;
    
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "No students match your search",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StudentCard(student: student),
        );
      },
    );
  }
}
