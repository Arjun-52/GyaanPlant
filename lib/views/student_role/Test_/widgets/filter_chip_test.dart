import 'package:flutter/material.dart';

class FilterChipTest extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipTest({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0D3A2A), Color(0xFF0A2E22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFF0A1F19),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00C853)
                  : const Color(0xFF00C853).withOpacity(0.1),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00E676)
                      : const Color(0xFF00C853).withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
