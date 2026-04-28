import 'package:flutter/material.dart';

class AvailabilitySection extends StatelessWidget {
  final Map<String, List<String>> availability;

  const AvailabilitySection({super.key, required this.availability});

  /// All possible time slots (shown every day)
  final List<String> allSlots = const ["3 PM", "4 PM", "5 PM", "6 PM"];

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
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: availability.entries.map((entry) {
              final day = entry.key;
              final availableSlots = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    /// DAY LABEL
                    SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    /// TIME SLOTS
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allSlots.map((slot) {
                          final isActive = availableSlots.contains(slot);

                          return timeChip(slot, isActive);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget timeChip(String time, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),

        /// ACTIVE = green glow
        color: isActive
            ? const Color(0xFF00C853).withOpacity(0.15)
            : Colors.transparent,

        /// BORDER STYLE
        border: Border.all(
          color: isActive ? const Color(0xFF00C853) : Colors.white24,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isActive ? const Color(0xFF00E676) : Colors.white38,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration boxStyle() => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: const LinearGradient(
      colors: [Color(0xFF0E2A1F), Color(0xFF081A14)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
  );
}
