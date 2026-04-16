import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';

class ReportsViewModel extends ChangeNotifier {
  final List<Report> reports = [
    Report(
      title: "Generate NAAC Report",
      subtitle: "Criterion 5.2 — Placement & Higher Studies",
      icon: "📋",
      isPrimary: true,
    ),
    Report(
      title: "Monthly Placement Summary",
      subtitle: "Feb 2026 • PDF",
      icon: "📄",
    ),
    Report(
      title: "Student Skill Gap Analysis",
      subtitle: "Q1 2026 • Excel",
      icon: "📊",
    ),
    Report(
      title: "Drive Outcome Report — TCS",
      subtitle: "Jan 2026 • PDF",
      icon: "📄",
    ),
    Report(
      title: "Department-wise Readiness",
      subtitle: "Feb 2026 • PDF",
      icon: "📈",
    ),
    Report(
      title: "NAAC Q2 Placement Data",
      subtitle: "Oct 2025 • PDF",
      icon: "📁",
    ),
  ];
}
