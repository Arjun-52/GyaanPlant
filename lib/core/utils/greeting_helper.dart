import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';

/// Reusable utility helper for user greetings based on local device time.
class GreetingHelper {
  GreetingHelper._();

  /// Gets the time-based greeting prefix according to system time:
  /// - 5:00 AM – 11:59 AM → Good Morning
  /// - 12:00 PM – 4:59 PM → Good Afternoon
  /// - 5:00 PM – 8:59 PM → Good Evening
  /// - 9:00 PM – 4:59 AM → Good Night
  static String getTimeGreetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  /// Capitalize or format the name or role fallback.
  static String formatNameOrRole(String? name, String? role) {
    if (name != null && name.trim().isNotEmpty && name.toLowerCase() != 'user') {
      final parts = name.trim().split(" ");
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0];
      }
    }

    if (role != null && role.trim().isNotEmpty) {
      final r = role.trim().toLowerCase();
      if (r == 'tpo') return 'TPO';
      if (r == 'hod') return 'HOD';
      if (r == 'admin') return 'Admin';
      return r[0].toUpperCase() + r.substring(1);
    }

    return 'User';
  }

  /// Returns the complete personalized greeting string with name or role fallback.
  /// Examples: "Good Morning, Arjun" or "Good Afternoon, TPO"
  static String getGreeting(String? name, String? role, {bool includeEmoji = true}) {
    final prefix = getTimeGreetingPrefix();
    final nameOrRole = formatNameOrRole(name, role);
    final emoji = includeEmoji ? " 👋" : "";
    return "$prefix, $nameOrRole$emoji";
  }
}
