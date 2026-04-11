import 'package:flutter/material.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final List<String> filters = ["All", "Aptitude", "Coding", "HR", "Company"];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                // Selected vs Unselected styles
                color: isSelected
                    ? const Color(0xFF00C853) // bright green
                    : const Color(0xFF0D1F1A), // dark background

                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00C853)
                      : const Color(0xFF1F5A4A),
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors
                            .black // selected text
                      : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
