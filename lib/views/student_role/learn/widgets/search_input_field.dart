import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  const SearchInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F1A), Color(0xFF12352B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: const Color(0xFF1F5A4A), width: 1),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.greenAccent,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          // Search Icon
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.greenAccent,
            size: 22,
          ),

          // Hint Text
          hintText: "Search courses, topics...",
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
