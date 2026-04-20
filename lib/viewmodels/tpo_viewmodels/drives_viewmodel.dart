import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';

class DrivesViewModel extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  final List<Drive> _drives = [
    Drive(
      company: "TCS",
      role: "Software Engineer",
      date: "Mar 22,\n2026",
      eligible: 342,
      registered: 298,
      pending: 44,
      status: "Upcoming",
    ),
    Drive(
      company: "Infosys",
      role: "Systems Engineer",
      date: "Mar 28,\n2026",
      eligible: 285,
      registered: 241,
      pending: 44,
      status: "Upcoming",
    ),
    Drive(
      company: "Wipro",
      role: "Project Engineer",
      date: "Apr 5,\n2026",
      eligible: 310,
      registered: 187,
      pending: 123,
      status: "Open",
    ),
  ];

  List<Drive> get drives => _drives;
}
