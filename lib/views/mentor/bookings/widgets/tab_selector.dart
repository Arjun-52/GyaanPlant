import 'package:flutter/material.dart';

class TabSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const TabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<String> tabs = const ["Pending", "Upcoming", "Completed"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D34).withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.1),
          width: 1.2,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: TabItem(text: tabs[index], active: selectedIndex == index),
            ),
          );
        }),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String text;
  final bool active;

  const TabItem({super.key, required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00E676) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color(0xFF031B15) : Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
