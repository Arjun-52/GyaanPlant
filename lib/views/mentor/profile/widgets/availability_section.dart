import 'package:flutter/material.dart';

class AvailabilitySection extends StatelessWidget {
  final Map<String, List<String>> availability;

  const AvailabilitySection({super.key, required this.availability});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Availability",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Column(
            children: availability.entries.map((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: TextStyle(color: Colors.grey)),
                  Row(
                    children: entry.value
                        .map((time) => timeChip(time))
                        .toList(),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget timeChip(String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(time, style: TextStyle(color: Colors.white)),
    );
  }

  BoxDecoration boxStyle() => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Colors.green.withOpacity(0.1),
  );
}
