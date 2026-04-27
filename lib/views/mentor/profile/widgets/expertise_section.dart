import 'package:flutter/material.dart';

class ExpertiseSection extends StatelessWidget {
  final List<String> expertise;

  const ExpertiseSection({super.key, required this.expertise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expertise",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: expertise.map((e) => chip(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Text(text, style: TextStyle(color: Colors.green)),
    );
  }

  BoxDecoration boxStyle() => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Colors.green.withOpacity(0.1),
  );
}
