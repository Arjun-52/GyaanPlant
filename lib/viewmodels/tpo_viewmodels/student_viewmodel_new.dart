import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

/// ViewModel for managing student data and UI state
class StudentViewModel extends ChangeNotifier {
  final _tpo = ApiService().tpo;

  // Private state
  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInitialized = false;

  // UI State
  String _searchQuery = "";
  String _selectedFilter = "All";

  // Public getters
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _students.isNotEmpty;
  bool get hasInitialized => _hasInitialized;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  /// Initialize ViewModel - called once when screen is created
  Future<void> initialize() async {
    if (_hasInitialized) return; // Prevent multiple initializations
    
    await fetchStudents();
    _hasInitialized = true;
  }

  /// Fetch students from API
  Future<void> fetchStudents() async {
    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Fetching students...");
      final result = await _tpo.getStudents();
      if (result.isSuccess) {
        _students = result.data ?? [];
      } else {
        throw Exception(result.error?.message ?? 'Failed to load students');
      }
      _errorMessage = null;
      
      print("Successfully fetched ${_students.length} students");
    } catch (e) {
      print("Error fetching students: $e");
      _errorMessage = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh students data (for pull-to-refresh)
  Future<void> refreshStudents() async {
    await fetchStudents();
  }

  /// Update search query
  void setSearch(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      notifyListeners();
    }
  }

  /// Update filter selection
  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Get filtered students based on search and filter
  List<Student> get filteredStudents {
    if (_students.isEmpty) return [];

    return _students.where((student) {
      // Search filter
      final matchesSearch = student.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          student.email.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Status/branch filter
      bool matchesFilter = true;
      
      switch (_selectedFilter) {
        case "MNC Ready":
          matchesFilter = student.status == "MNC Ready";
          break;
        case "At Risk":
          matchesFilter = student.status == "At Risk";
          break;
        case "Average":
          matchesFilter = student.status == "Average";
          break;
        case "All":
          matchesFilter = true; // No filtering
          break;
        default:
          // For branch filters
          matchesFilter = student.branch == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Get available filter options (based on actual data)
  List<String> get availableFilters {
    final filters = <String>{"All"};
    
    // Add status-based filters
    final statuses = _students.map((s) => s.status).toSet();
    filters.addAll(statuses);
    
    // Add branch filters
    final branches = _students.map((s) => s.branch).where((b) => b != "N/A").toSet();
    filters.addAll(branches);
    
    return filters.toList();
  }

  /// Get statistics
  Map<String, int> get statistics {
    final stats = <String, int>{
      'total': _students.length,
      'mncReady': 0,
      'atRisk': 0,
      'average': 0,
    };

    for (final student in _students) {
      switch (student.status) {
        case "MNC Ready":
          stats['mncReady'] = (stats['mncReady'] ?? 0) + 1;
          break;
        case "At Risk":
          stats['atRisk'] = (stats['atRisk'] ?? 0) + 1;
          break;
        case "Average":
          stats['average'] = (stats['average'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  /// Debug helper
  @override
  String toString() {
    return 'StudentViewModel(students: ${_students.length}, isLoading: $_isLoading, hasError: $_errorMessage != null)';
  }
}
