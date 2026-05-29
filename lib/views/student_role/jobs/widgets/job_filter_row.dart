import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/student_viewmodel/job_viewmodel.dart';

class JobFilterRow extends StatelessWidget {
  const JobFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JobViewModel>(context);

    final filters = ["All Opportunities", "Fresher Roles", "Internships", "Remote Jobs", "Hyderabad"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = vm.selectedFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => vm.selectFilter(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0x1F00E676)
                      : const Color(0xFF031410),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00E676)
                        : const Color(0xFF00E676).withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.1),
                        blurRadius: 8,
                      ),
                  ],
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF00E676) : Colors.white60,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
