import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class StudentViewModel extends ChangeNotifier {
  final _tpo = ApiService().tpo;

  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _students.isNotEmpty;
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
    print('🚀 StudentViewModel.initialize() called');
    await fetchStudents();
  }

  Future<void> fetchStudents() async {
    print('📡 StudentViewModel.fetchStudents() called');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // STEP 1: FETCH COLLEGE ID FROM USER
      print('🏫 Fetching current user to get collegeId...');
      final userRes = await ApiService().auth.getCurrentUser();

      print("👤 USER RESPONSE OBJECT: $userRes");
      print("👤 USER DATA: ${userRes.data}");

      final college = userRes.data?.college;
      String? collegeId;

      if (college == null) {
        print('❌ College data is null');
      } else {
        collegeId = college.id;
        print('🏫 College ID extracted: $collegeId');
        print('🏫 College name: ${college.name}');
      }

      // STEP 2: SAFETY CHECKS
      if (collegeId == null) {
        print('❌ No collegeId found, skipping API call');
        _errorMessage = 'No college assigned to user';
        _students = [];
        return;
      }

      print('🏫 Using collegeId for filtering: $collegeId');
      print('🏫 collegeId type: ${collegeId.runtimeType}');

      // STEP 3: UPDATE VIEWMODEL CALL
      print('�� Calling API: _tpo.getStudents(collegeId)');
      final result = await _tpo.getStudents(collegeId);
      print(
        '📦 API Response: isSuccess=${result.isSuccess}, data=${result.data}',
      );

      if (result.isSuccess) {
        _students = result.data ?? [];
        print('✅ Successfully loaded ${_students.length} students');
        print('📊 FILTERED STUDENTS COUNT: ${_students.length}');

        if (_students.isNotEmpty) {
          print('📊 First student name: ${_students.first.name}');
        }
      } else {
        throw Exception(result.error?.message ?? 'Failed to load students');
      }
    } catch (e) {
      print('❌ Error fetching students: $e');
      _errorMessage = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 fetchStudents() completed');
    }
  }

  Future<void> refreshStudents() async => fetchStudents();

  void addStudentLocal(Student student) {
    _students.insert(0, student);
    notifyListeners();
  }

  void updateStudentLocal(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  String _generateInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _normalizeBranch(String branch) {
    final value = branch.trim();
    switch (value.toUpperCase()) {
      case 'MECH':
        return 'Mechanical';
      case 'CIVIL':
        return 'Civil';
      default:
        return value;
    }
  }

  Future<void> updateStudent({
    required Student currentStudent,
    required String id,
    required String name,
    required String email,
    required String branchId,
    required String branchName,
    required int year,
    required String rollNo,
    required double cgpa,
    required String careerPath,
  }) async {
    final payload = {
      'name': name,
      'email': email,
      'branch': branchId,
      'year': year,
      'rollNo': rollNo,
      'rollNumber': rollNo,
      'cgpa': cgpa,
      'careerPath': careerPath,
    };

    print('Student ID: $id');
    print('Payload: $payload');

    final response = await ApiService().student.updateStudent(id, payload);
    print('Update response: ${response.data}');

    if (response.isSuccess && response.data != null) {
      final updatedStudent = Student(
        id: currentStudent.id,
        name: name,
        email: email,
        branch: branchName,
        branchId: branchId,
        year: 'Year $year',
        score: currentStudent.score,
        status: currentStudent.status,
        initials: _generateInitials(name),
        rollNo: rollNo,
        cgpa: cgpa,
        careerPath: careerPath,
      );
      updateStudentLocal(updatedStudent);
    } else {
      throw Exception(response.error?.message ?? 'Failed to update student.');
    }
  }

  Future<void> onboardStudent({
    required String name,
    required String email,
    required String branch,
    required String year,
    required String rollNo,
    required double cgpa,
    required String careerPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRes = await ApiService().auth.getCurrentUser();
      final currentUserId = userRes.data?.id;
      print('🔐 Current user (auth) response: $userRes');
      print('🔑 Current user id: $currentUserId');
      final collegeId = userRes.data?.college?.id;

      if (collegeId == null) {
        throw Exception('No college assigned to TPO');
      }

      // Convert "Year 3" -> 3
      final yearNum = int.tryParse(year.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      final normalizedBranch = _normalizeBranch(branch);

      print('📨 Onboard payload preview: {name: $name, email: $email, branch: $normalizedBranch, year: $yearNum, rollNo: $rollNo, cgpa: $cgpa, careerPath: $careerPath, college: $collegeId}');

      final result = await _tpo.onboardStudent(
        name: name,
        email: email,
        branch: normalizedBranch,
        year: yearNum,
        rollNo: rollNo,
        cgpa: cgpa,
        careerPath: careerPath,
        collegeId: collegeId,
      );

      print('📥 Onboard API result: isSuccess=${result.isSuccess}, error=${result.error}, data=${result.data}');

      if (result.isSuccess && result.data != null) {
        _students.insert(0, result.data!);
      } else {
        throw Exception(result.error?.message ?? 'Failed to onboard student');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
          student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.rollNo.toLowerCase().contains(_searchQuery.toLowerCase());

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
          matchesFilter =
              _selectedFilter == 'All' || student.branch == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get availableFilters {
    final filters = <String>{'All'};
    filters.addAll(_students.map((s) => s.status).toSet());
    filters.addAll(
      _students.map((s) => s.branch).where((b) => b != 'N/A').toSet(),
    );
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
