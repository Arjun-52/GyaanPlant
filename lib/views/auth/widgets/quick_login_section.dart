import 'package:flutter/material.dart';
import 'quick_login_item.dart';
import 'section_title.dart';

class QuickLoginSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const QuickLoginSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: QuickLoginItem(icon: item['icon'], text: item['text']),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
