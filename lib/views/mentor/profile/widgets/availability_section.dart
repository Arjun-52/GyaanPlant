import 'package:flutter/material.dart';

class AvailabilitySection extends StatelessWidget {
  final Map<String, List<String>> availability;
  final Function(String day, String time) onToggle;

  const AvailabilitySection({
    super.key,
    required this.availability,
    required this.onToggle,
  });

  /// All possible time slots (shown every day)
  final List<String> allSlots = const ["3 PM", "4 PM", "5 PM", "6 PM"];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0C241B).withOpacity(0.4),
            const Color(0xFF04100C).withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF00E676),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Availability",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: ["Mon", "Tue", "Wed", "Thu", "Fri"].map((day) {
              final availableSlots = availability[day] ?? [];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// DAY LABEL
                    SizedBox(
                      width: 48,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
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

                          return GestureDetector(
                            onTap: () => onToggle(day, slot),
                            child: timeChip(slot, isActive),
                          );
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive
              ? const Color(0xFF00E676).withOpacity(0.15)
              : const Color(0xFF1A1A1A).withOpacity(0.4),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00E676)
                : const Color(0xFF00E676).withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isActive ? const Color(0xFF00E676) : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

