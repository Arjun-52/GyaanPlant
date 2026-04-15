import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';

class StudentViewModel extends ChangeNotifier {
  final List<Student> _students = [
    Student(
      name: "Arjun Kumar",
      branch: "CSE",
      year: "4th Year",
      score: 92,
      initials: "AK",
    ),
    Student(
      name: "Sneha Murthy",
      branch: "IT",
      year: "4th Year",
      score: 88,
      initials: "SM",
    ),
    Student(
      name: "Ravi Teja",
      branch: "CSE",
      year: "4th Year",
      score: 81,
      initials: "RT",
    ),
    Student(
      name: "Divya Sharma",
      branch: "ECE",
      year: "4th Year",
      score: 76,
      initials: "DS",
    ),
    Student(
      name: "Karthik Nair",
      branch: "CSE",
      year: "3rd Year",
      score: 69,
      initials: "KN",
    ),
  ];

  String _searchQuery = "";

  String _selectedFilter = "All";

  List<Student> get students => _students;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Student> get filteredStudents {
    return _students.where((student) {
      final matchesSearch = student.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      bool matchesFilter = true;

      if (_selectedFilter == "MNC Ready") {
        matchesFilter = student.score >= 75;
      } else if (_selectedFilter == "At-Risk") {
        matchesFilter = student.score < 75;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }
}
