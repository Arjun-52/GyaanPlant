import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const TabItem(this.text, this.active, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00C853) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.black : Colors.white54,
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
