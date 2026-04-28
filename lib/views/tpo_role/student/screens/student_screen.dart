import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/student/widgets/filter_chip.dart';
import 'package:gyaanplant/views/tpo_role/student/widgets/student_card.dart';
import 'package:provider/provider.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late final StudentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = StudentViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
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
                    const Text('Students',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.students.length} total · ${vm.students.where((e) => e.score >= 75).length} drive-ready',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: vm.setSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name, roll number...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF0F2A22),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: Colors.green.withValues(alpha: 0.1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'MNC Ready', 'At-Risk', 'ECE', 'CSE']
                            .map((label) => Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: StudentFilterChip(
                                    label: label,
                                    isSelected: vm.selectedFilter == label,
                                    onTap: () => vm.setFilter(label),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: vm.filteredStudents.isEmpty
                          ? const Center(
                              child: Text('No students found',
                                  style: TextStyle(color: Colors.white54)))
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
      ),
    );
  }
}
