import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/job_viewmodel.dart';

class JobFilterRow extends StatelessWidget {
  const JobFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JobViewModel>(context);

    final filters = ["All", "Fresher", "Internships", "Remote", "Hyderabad"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = vm.selectedFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => vm.selectFilter(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C853)
                        : Colors.green.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  color: isSelected
                      ? const Color(0xFF00C853)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white54,
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
