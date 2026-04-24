import 'package:flutter/material.dart';

class TabSelector extends StatefulWidget {
  final Function(int)? onTabChanged;

  const TabSelector({super.key, this.onTabChanged});

  @override
  State<TabSelector> createState() => _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  int selectedIndex = 0;

  final List<String> tabs = ["Pending", "Upcoming", "Completed"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F1A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                /// optional callback to parent
                if (widget.onTabChanged != null) {
                  widget.onTabChanged!(index);
                }
              },
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF16C47F) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
