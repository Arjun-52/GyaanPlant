import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/mentor_viewmodel/mentor_profile_viewmodel.dart';

class AvailabilitySection extends StatefulWidget {
  final Map<String, List<String>> availability;
  final Function(String dayOrDate, String time) onToggle;

  const AvailabilitySection({
    super.key,
    required this.availability,
    required this.onToggle,
  });

  @override
  State<AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<AvailabilitySection> {
  bool isWeeklyMode = true; // Toggle between weekly recurring and specific date
  String selectedDay = "Mon";
  DateTime selectedDate = DateTime.now();

  final List<String> allSlots = const ["3 PM", "4 PM", "5 PM", "6 PM"];

  final List<String> weekdays = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  String get activeKey {
    if (isWeeklyMode) {
      return selectedDay;
    } else {
      // YYYY-MM-DD format
      return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    }
  }

  String _formatDateString(String key) {
    final cleanKey = key.trim().toLowerCase();
    final dayNames = {
      "mon": "Mondays",
      "tue": "Tuesdays",
      "wed": "Wednesdays",
      "thu": "Thursdays",
      "fri": "Fridays",
      "sat": "Saturdays",
      "sun": "Sundays",
    };

    if (dayNames.containsKey(cleanKey)) {
      return "Weekly on ${dayNames[cleanKey]}";
    }

    try {
      final parsed = DateTime.parse(key);
      final months = [
        "January", "February", "March", "April", "May", "June", 
        "July", "August", "September", "October", "November", "December"
      ];
      final weekdaysFull = [
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
      ];
      final weekdayName = weekdaysFull[parsed.weekday % 7];
      return "$weekdayName, ${parsed.day} ${months[parsed.month - 1]} ${parsed.year}";
    } catch (_) {
      return key;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 305)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Colors.black,
              surface: Color(0xFF0C1612),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF020B08),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MentorProfileViewModel>();
    final activeSlots = widget.availability[activeKey] ?? [];

    return Column(
      children: [
        /// 1. AVAILABILITY STATUS CARD
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00E676).withOpacity(0.08),
                const Color(0xFF020B08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF00E676).withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.02),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Availability Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (vm.lastUpdated != null)
                    Text(
                      "Saved: ${vm.lastUpdated}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem("Available Days", "${vm.availableDaysCount}", Icons.date_range_rounded),
                  _statItem("Total Slots", "${vm.availableSlotsCount}", Icons.watch_later_rounded),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFF00E676), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Next Session:  ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      vm.nextAvailableSession,
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// 2. MAIN SCHEDULER CONTROLLER CARD
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Color(0xFF00E676),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Set Availability",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Weekly Recurring vs Specific Date Selector Tabs
              Row(
                children: [
                  Expanded(
                    child: _modeTab("Weekly Recurring", isWeeklyMode, () {
                      setState(() {
                        isWeeklyMode = true;
                      });
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modeTab("Specific Date", !isWeeklyMode, () {
                      setState(() {
                        isWeeklyMode = false;
                      });
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Day Selection (Weekly) OR Date Picker Selection (Specific Date)
              if (isWeeklyMode) ...[
                const Text(
                  "Select Day",
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekdays.length,
                    itemBuilder: (context, index) {
                      final d = weekdays[index];
                      final isActive = selectedDay == d;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDay = d;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  color: isActive ? const Color(0xFF00E676) : Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const Text(
                  "Select Date",
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF00E676), size: 18),
                            const SizedBox(width: 12),
                            Text(
                              "${selectedDate.day} ${_formatDateMonth(selectedDate.month)} ${selectedDate.year}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_rounded, color: Color(0xFF00E676), size: 16),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Time Slots Grid
              const Text(
                "Select Time Slots",
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allSlots.map((slot) {
                  final isActive = activeSlots.contains(slot);
                  return GestureDetector(
                    onTap: () {
                      widget.onToggle(activeKey, slot);
                    },
                    child: timeChip(slot, isActive),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        /// 3. SAVED AVAILABILITY LIST SECTION
        if (widget.availability.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E676), size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Saved Schedule Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${widget.availability.length} active",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...widget.availability.entries.map((entry) {
            final key = entry.key;
            final slots = entry.value;
            if (slots.isEmpty) return const SizedBox();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF0C1612).withOpacity(0.8),
                border: Border.all(
                  color: const Color(0xFF00E676).withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateString(key),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: slots.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF00E676).withOpacity(0.15),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delete Button
                      IconButton(
                        onPressed: () {
                          vm.removeDayOrDate(key);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        tooltip: "Delete schedule",
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive ? const Color(0xFF00E676).withOpacity(0.08) : Colors.white.withOpacity(0.03),
          border: Border.all(
            color: isActive ? const Color(0xFF00E676) : Colors.white.withOpacity(0.05),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF00E676) : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDateMonth(int month) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Widget timeChip(String time, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive ? const Color(0xFF00E676).withOpacity(0.15) : const Color(0xFF1A1A1A).withOpacity(0.4),
        border: Border.all(
          color: isActive ? const Color(0xFF00E676) : const Color(0xFF00E676).withOpacity(0.15),
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
    );
  }
}
