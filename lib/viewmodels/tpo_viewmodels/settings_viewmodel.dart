import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/settings_item_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _disposed = false;

  // User information
  String userName = "Loading...";

  // College information
  String collegeName = "Loading...";

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<SettingsItem> _items = [
    SettingsItem(
      title: "Security & Privacy",
      subtitle: "2FA enabled",
      icon: "🔒",
    ),
  ];

  List<SettingsItem> get items => _items;

  /// Fetch college name dynamically using collegeId from user profile
  Future<void> fetchCollegeName() async {
    print("🏫 Settings: Fetching college name...");

    try {
      // Step 1: Get current user to extract collegeId
      final userResult = await ApiService().auth.getCurrentUser();

      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data!;

        // Extract and store user name
        userName = user.name;
        print("👤 Settings: User name extracted: $userName");

        final college = user.college;

        print("🏫 Settings: College object: $college");

        if (college != null && college.id != null) {
          // Step 2: Fetch college details using collegeId
          final collegeResult = await ApiService().college.getCollegeById(
            college.id!,
          );

          print("🏫 Settings: College Response: ${collegeResult.data}");

          if (collegeResult.isSuccess && collegeResult.data != null) {
            final collegeData = collegeResult.data!;

            // Safe extraction of college name
            Map<String, dynamic> collegeInfo = collegeData;

            // Extract college name safely
            if (collegeInfo.containsKey('name')) {
              collegeName = collegeInfo['name'];
              print("🏫 Settings: Final College Name: $collegeName");
            } else {
              collegeName = "Unknown College";
              print("⚠️ Settings: College name not found in response");
            }
          } else {
            collegeName = "Error loading college";
            print(
              "❌ Settings: College API failed: ${collegeResult.error?.message}",
            );
          }
        } else {
          collegeName = "No College Assigned";
          print("⚠️ Settings: No college ID found for user");
        }
      } else {
        collegeName = "Error loading user";
        print(
          "❌ Settings: Failed to get current user: ${userResult.error?.message}",
        );
      }
    } catch (e) {
      collegeName = "Error loading college";
      print("💥 Settings: Exception in fetchCollegeName: $e");
    }

    // Notify listeners to update UI
    notifyListeners();
  }

  /// Initialize ViewModel - called when screen is first created
  void initialize() {
    print("🧠 Settings ViewModel initialize() called");
    fetchCollegeName();
  }
}
