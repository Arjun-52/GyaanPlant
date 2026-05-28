import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String) onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52, // Standard premium input height
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF061410).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF132B22),
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0x9900E676), // Opacity-reduced accent green
            size: 24,
          ),
          dropdownColor: const Color(0xFF0D1F1A), // Premium dark surface card color
          style: const TextStyle(
            color: Color(0xE6FFFFFF),
            fontSize: 15,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }
}

