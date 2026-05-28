import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final List<String> filters = const ["All", "Aptitude", "Coding", "HR", "Company"];

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningViewModel>(
      builder: (context, vm, child) {
        return SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = filters[index];
              final isSelected = vm.selectedCategory.toLowerCase() == category.toLowerCase();

              return GestureDetector(
                onTap: () {
                  Feedback.forTap(context);
                  vm.updateSelectedCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF071411), Color(0xFF0B1914)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00E676)
                          : const Color(0xFF163E33),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: const Color(0xFF00B0FF).withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Gilroy-Semibold',
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF020B08)
                            : Colors.white.withValues(alpha: 0.65),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


