import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class StudentViewModel extends ChangeNotifier {
  final _tpo = ApiService().tpo;

  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInitialized = false;
  bool _disposed = false;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _students.isNotEmpty;
  bool get hasInitialized => _hasInitialized;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> initialize() async {
    if (_hasInitialized) return;
    await fetchStudents();
    _hasInitialized = true;
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _tpo.getStudents();
      if (result.isSuccess) {
        _students = result.data ?? [];
      } else {
        throw Exception(result.error?.message ?? 'Failed to load students');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStudents() async => fetchStudents();

  void setSearch(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  List<Student> get filteredStudents {
    if (_students.isEmpty) return [];

    return _students.where((student) {
      final matchesSearch =
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'MNC Ready':
          matchesFilter = student.status == 'MNC Ready';
          break;
        case 'At Risk':
          matchesFilter = student.status == 'At Risk';
          break;
        case 'Average':
          matchesFilter = student.status == 'Average';
          break;
        default:
          matchesFilter = _selectedFilter == 'All' || student.branch == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get availableFilters {
    final filters = <String>{'All'};
    filters.addAll(_students.map((s) => s.status).toSet());
    filters.addAll(_students.map((s) => s.branch).where((b) => b != 'N/A').toSet());
    return filters.toList();
  }

  Map<String, int> get statistics {
    final stats = <String, int>{
      'total': _students.length,
      'mncReady': 0,
      'atRisk': 0,
      'average': 0,
    };
    for (final student in _students) {
      switch (student.status) {
        case 'MNC Ready':
          stats['mncReady'] = (stats['mncReady'] ?? 0) + 1;
          break;
        case 'At Risk':
          stats['atRisk'] = (stats['atRisk'] ?? 0) + 1;
          break;
        case 'Average':
          stats['average'] = (stats['average'] ?? 0) + 1;
          break;
      }
    }
    return stats;
  }
}
