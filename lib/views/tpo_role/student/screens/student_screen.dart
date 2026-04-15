import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/student/widgets/filter_chip.dart';
import 'package:gyaanplant/views/tpo_role/student/widgets/student_card.dart';
import 'package:provider/provider.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<StudentViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///  HEADER
                    const Text(
                      "Students 👥",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${vm.students.length} total • ${vm.students.where((e) => e.score >= 75).length} drive-ready",
                      style: const TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 16),

                    ///  SEARCH
                    TextField(
                      onChanged: vm.setSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search by name, roll number...",
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
                    ),

                    const SizedBox(height: 12),

                    ///  FILTERS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StudentFilterChip(
                            label: "All",
                            isSelected: vm.selectedFilter == "All",
                            onTap: () => vm.setFilter("All"),
                          ),
                          const SizedBox(width: 20),
                          StudentFilterChip(
                            label: "MNC Ready",
                            isSelected: vm.selectedFilter == "MNC Ready",
                            onTap: () => vm.setFilter("MNC Ready"),
                          ),
                          const SizedBox(width: 20),
                          StudentFilterChip(
                            label: "At-Risk",
                            isSelected: vm.selectedFilter == "At-Risk",
                            onTap: () => vm.setFilter("At-Risk"),
                          ),
                          const SizedBox(width: 20),
                          StudentFilterChip(
                            label: "ECE",
                            isSelected: vm.selectedFilter == "ECE",
                            onTap: () => vm.setFilter("ECE"),
                          ),
                          const SizedBox(width: 20),
                          StudentFilterChip(
                            label: "CSE",
                            isSelected: vm.selectedFilter == "CSE",
                            onTap: () => vm.setFilter("CSE"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// STUDENT LIST (FILTERED)
                    Expanded(
                      child: vm.filteredStudents.isEmpty
                          ? const Center(
                              child: Text(
                                "No students found",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.separated(
                              itemCount: vm.filteredStudents.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  StudentCard(student: vm.filteredStudents[i]),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const TpoBottomNav(currentIndex: 1),
      ),
    );
  }
}
