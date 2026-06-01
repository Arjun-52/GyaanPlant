import 'package:flutter/material.dart';
import '../../models/mentor_models/mentor_dashboard_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';

class MentorProfileViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;
  bool isSaving = false;
  String? lastUpdated;

  ///  LOCAL EDITABLE STATE
  List<String> _expertise = [];
  Map<String, List<String>> _availability = {};

  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  /// GETTERS FOR STATISTICS
  int get availableDaysCount => _availability.keys.length;

  int get availableSlotsCount =>
      _availability.values.fold(0, (sum, slots) => sum + slots.length);

  String get nextAvailableSession {
    if (_availability.isEmpty) return "None scheduled";

    final now = DateTime.now();
    DateTime? earliestDate;
    String? earliestTime;

    final daysOfWeek = {
      "mon": DateTime.monday,
      "tue": DateTime.tuesday,
      "wed": DateTime.wednesday,
      "thu": DateTime.thursday,
      "fri": DateTime.friday,
      "sat": DateTime.saturday,
      "sun": DateTime.sunday,
      "monday": DateTime.monday,
      "tuesday": DateTime.tuesday,
      "wednesday": DateTime.wednesday,
      "thursday": DateTime.thursday,
      "friday": DateTime.friday,
      "saturday": DateTime.saturday,
      "sunday": DateTime.sunday,
    };

    for (final entry in _availability.entries) {
      final key = entry.key.trim().toLowerCase();
      final slots = entry.value;
      if (slots.isEmpty) continue;

      // Make a copy and sort slots so we take the earliest one
      final sortedSlots = List<String>.from(slots);
      sortedSlots.sort((a, b) => _parseSlotHour(a).compareTo(_parseSlotHour(b)));
      final earliestSlot = sortedSlots.first;

      DateTime? targetDate;
      if (daysOfWeek.containsKey(key)) {
        // It's a recurring day
        final targetWeekday = daysOfWeek[key]!;
        int daysToAdd = targetWeekday - now.weekday;
        if (daysToAdd < 0) {
          daysToAdd += 7; // Next week
        } else if (daysToAdd == 0) {
          // Today, check if slot hour has already passed
          final hour = _parseSlotHour(earliestSlot);
          if (now.hour >= hour) {
            daysToAdd = 7; // Next week
          }
        }
        targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: daysToAdd));
      } else {
        // It's a specific date "YYYY-MM-DD" or similar
        try {
          final parsed = DateTime.parse(entry.key);
          if (parsed.isAfter(now) || (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day)) {
            // Check if it's today but hour has passed
            if (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day) {
              final hour = _parseSlotHour(earliestSlot);
              if (now.hour < hour) {
                targetDate = parsed;
              }
            } else {
              targetDate = parsed;
            }
          }
        } catch (_) {
          // If we fail to parse, maybe format is "DD MMM YYYY" or similar
        }
      }

      if (targetDate != null) {
        if (earliestDate == null || targetDate.isBefore(earliestDate)) {
          earliestDate = targetDate;
          earliestTime = earliestSlot;
        }
      }
    }

    if (earliestDate != null && earliestTime != null) {
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      final weekdayName = dayNames[earliestDate.weekday % 7];
      return "$weekdayName, ${earliestDate.day} ${months[earliestDate.month - 1]} @ $earliestTime";
    }

    return "None scheduled";
  }

  int _parseSlotHour(String slot) {
    final clean = slot.toUpperCase().replaceAll(" ", "");
    final isPM = clean.contains("PM");
    final numberStr = clean.replaceAll("AM", "").replaceAll("PM", "");
    final hour = int.tryParse(numberStr) ?? 12;
    if (isPM && hour != 12) return hour + 12;
    if (!isPM && hour == 12) return 0;
    return hour;
  }

  ///  LOAD
  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      lastUpdated = await LocalStorageService.getAvailabilityLastUpdated();
      final result = await _mentor.getDashboard();

      if (result.isSuccess && result.data != null) {
        dashboard = result.data;

        _expertise = List.from(dashboard!.skills);
        
        final cachedAvailability = await LocalStorageService.getAvailability();
        if (cachedAvailability != null && cachedAvailability.isNotEmpty) {
          _availability = cachedAvailability;
        } else {
          _availability = Map.from(dashboard!.availability);
        }
      }
    } catch (e) {
      dashboard = null;
    }

    isLoading = false;
    notifyListeners();
  }

  /// GETTER
  String get name => dashboard?.name ?? "Mentor";
  String get role => dashboard?.role ?? "FSD";
  double get rating => dashboard?.rating ?? 0.0;
  int get sessions => dashboard?.sessionsDone ?? 0;

  List<String> get expertise =>
      _expertise.isNotEmpty ? _expertise : ["Data Structures", "System Design"];

  Map<String, List<String>> get availability => _availability;

  /// UPDATE EXPERTISE
  void toggleExpertise(String skill) {
    if (_expertise.isEmpty && dashboard != null) {
      _expertise = List.from(dashboard!.skills);
    }

    if (_expertise.contains(skill)) {
      _expertise.remove(skill);
    } else {
      _expertise.add(skill);
    }

    _hasChanges = true;
    notifyListeners();
  }

  /// UPDATE AVAILABILITY
  void toggleTime(String day, String time) {
    _availability.putIfAbsent(day, () => []);

    if (_availability[day]!.contains(time)) {
      _availability[day]!.remove(time);
      if (_availability[day]!.isEmpty) {
        _availability.remove(day);
      }
    } else {
      _availability[day]!.add(time);
    }

    _hasChanges = true;
    notifyListeners();
  }

  /// REMOVE ALL SLOTS FOR A SPECIFIC DAY OR DATE
  void removeDayOrDate(String key) {
    if (_availability.containsKey(key)) {
      _availability.remove(key);
      _hasChanges = true;
      notifyListeners();
    }
  }

  String _formatCurrentTimestamp() {
    final now = DateTime.now();
    final months = [
      "June", // Standard mock date is 15 June 2026, let's format current dynamic time nicely:
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    final monthStr = months[now.month];
    
    int hour = now.hour;
    final period = hour >= 12 ? "PM" : "AM";
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minuteStr = now.minute.toString().padLeft(2, '0');
    
    return "${now.day} $monthStr ${now.year} • $hour:$minuteStr $period";
  }

  ///  SAVE
  Future<String?> saveProfile() async {
    if (!_hasChanges) return 'No changes to save';

    isSaving = true;
    notifyListeners();

    try {
      final result = await _mentor.updateProfile({
        "mentor": {
          "skills": _expertise,
          "availability": _availability,
        }
      });

      if (result.isSuccess) {
        _hasChanges = false;
        
        final timestampStr = _formatCurrentTimestamp();
        await LocalStorageService.saveAvailabilityLastUpdated(timestampStr);
        await LocalStorageService.saveAvailability(_availability);
        lastUpdated = timestampStr;

        // Sync local dashboard state to avoid needing a full screen reload
        if (dashboard != null) {
          dashboard = MentorDashboardModel(
            name: dashboard!.name,
            role: dashboard!.role,
            sessionsDone: dashboard!.sessionsDone,
            earnings: dashboard!.earnings,
            rating: dashboard!.rating,
            skills: List.from(_expertise),
            availability: Map.from(_availability),
            upcomingSessions: dashboard!.upcomingSessions,
            recentSessions: dashboard!.recentSessions,
          );
        }
        isSaving = false;
        notifyListeners();
        return null; // Success
      } else {
        isSaving = false;
        notifyListeners();
        return result.error?.message ?? 'Failed to update profile';
      }
    } catch (e) {
      debugPrint("Save error: $e");
      isSaving = false;
      notifyListeners();
      return e.toString();
    }
  }
}
