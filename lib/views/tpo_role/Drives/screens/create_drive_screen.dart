import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/form_section_card.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/form_text_field.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/date_picker_field.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/branch_selection_chips.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/jd_upload_widget.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/bottom_cta_button.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';

class CreateDriveScreen extends StatefulWidget {
  const CreateDriveScreen({super.key});

  @override
  State<CreateDriveScreen> createState() => _CreateDriveScreenState();
}

class _CreateDriveScreenState extends State<CreateDriveScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _ctcController = TextEditingController();
  final _cgpaController = TextEditingController();

  DateTime? _driveDate;
  DateTime? _registrationDeadline;

  final List<String> _availableBranches = [
    'CSE', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL', 'AIML', 'AIDS', 'CSBS',
  ];
  final Set<String> _selectedBranches = <String>{};

  String? _jdFilePath;
  bool _isSubmitting = false;

  List<Department> _departments = [];
  bool _isLoadingDepartments = true;
  String? _departmentsError;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      print('📡 Fetching departments from HOD API for branch mapping...');
      final result = await ApiService().hod.getDepartments();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _departments = result.data!;
          _isLoadingDepartments = false;
        });
        print('✅ Loaded ${_departments.length} departments for branch mapping.');
      } else {
        setState(() {
          _departmentsError = result.error?.message ?? 'Failed to load branches';
          _isLoadingDepartments = false;
        });
        print('⚠️ Failed to load departments: $_departmentsError');
      }
    } catch (e) {
      setState(() {
        _departmentsError = e.toString();
        _isLoadingDepartments = false;
      });
      print('💥 Exception loading departments: $e');
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _ctcController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF00C853)),
    );
  }

  Future<void> _selectDate({required bool isDriveDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C853),
              surface: Color(0xFF061A14),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDriveDate) {
          _driveDate = picked;
        } else {
          _registrationDeadline = picked;
        }
      });
    }
  }

  void _onJDPick(String? filePath) {
    if (filePath != null) {
      setState(() {
        _jdFilePath = filePath;
      });
    }
  }

  void _toggleBranch(String branch) {
    setState(() {
      if (_selectedBranches.contains(branch)) {
        _selectedBranches.remove(branch);
      } else {
        _selectedBranches.add(branch);
      }
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    if (_driveDate == null) {
      _showErrorSnackBar('Please select drive schedule date');
      return false;
    }
    if (_registrationDeadline == null) {
      _showErrorSnackBar('Please select registration deadline');
      return false;
    }
    if (_selectedBranches.isEmpty) {
      _showErrorSnackBar('Please select at least one eligible branch');
      return false;
    }
    if (_registrationDeadline!.isAfter(_driveDate!)) {
      _showErrorSnackBar('Registration deadline must be before drive date');
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;
    setState(() => _isSubmitting = true);

    try {
      // ── MAPPING BRANCH NAMES TO BACKEND OBJECTIDS ──────────────────────────
      final List<String> branchIds = [];
      final List<String> invalidIds = [];
      final List<String> unmatchedBranches = [];

      for (final selectedBranch in _selectedBranches) {
        final normalizedSelected = selectedBranch.trim().toUpperCase();
        Department? matchedDept;

        // 1. Try matching by code
        for (final dept in _departments) {
          if (dept.code != null && dept.code!.trim().toUpperCase() == normalizedSelected) {
            matchedDept = dept;
            break;
          }
        }

        // 2. Try matching by name
        if (matchedDept == null) {
          for (final dept in _departments) {
            if (dept.name.trim().toUpperCase() == normalizedSelected) {
              matchedDept = dept;
              break;
            }
          }
        }

        // 3. Normalized fallback comparison
        if (matchedDept == null) {
          String normalize(String b) {
            switch (b.trim().toUpperCase()) {
              case 'MECH': return 'MECHANICAL';
              case 'CIVIL': return 'CIVIL';
              case 'CSE': return 'COMPUTER SCIENCE';
              case 'ECE': return 'ELECTRONICS';
              case 'EEE': return 'ELECTRICAL';
              case 'IT': return 'INFORMATION TECHNOLOGY';
              default: return b.trim().toUpperCase();
            }
          }
          
          final normSelected = normalize(normalizedSelected);
          for (final dept in _departments) {
            final normDeptName = normalize(dept.name);
            final normDeptCode = dept.code != null ? normalize(dept.code!) : '';
            if (normDeptName.contains(normSelected) || normSelected.contains(normDeptName) ||
                (normDeptCode.isNotEmpty && (normDeptCode.contains(normSelected) || normSelected.contains(normDeptCode)))) {
              matchedDept = dept;
              break;
            }
          }
        }

        if (matchedDept != null) {
          // Verify ID is a valid MongoDB ObjectId (24 hex characters)
          final deptId = matchedDept.id;
          if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(deptId)) {
            branchIds.add(deptId);
          } else {
            invalidIds.add('$selectedBranch (ID: $deptId)');
          }
        } else {
          unmatchedBranches.add(selectedBranch);
        }
      }

      print('🧬 Mapped branch IDs: $branchIds');
      if (invalidIds.isNotEmpty) {
        print('⚠️ Invalid MongoDB ObjectIds detected: $invalidIds');
      }
      if (unmatchedBranches.isNotEmpty) {
        print('⚠️ Could not match branches: $unmatchedBranches');
      }

      if (branchIds.isEmpty) {
        _showErrorSnackBar(
          'Error matching branches: Could not locate database IDs for selected branches. '
          'Please wait for branches to load or pull to refresh.',
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // ── Build the API payload ─────────────────────────────────────────────
      final String driveDateStr =
          '${_driveDate!.year}-${_driveDate!.month.toString().padLeft(2, '0')}-${_driveDate!.day.toString().padLeft(2, '0')}';
      final String deadlineStr =
          '${_registrationDeadline!.year}-${_registrationDeadline!.month.toString().padLeft(2, '0')}-${_registrationDeadline!.day.toString().padLeft(2, '0')}';

      final payload = <String, dynamic>{
        'company': _companyController.text.trim(),
        'role': _roleController.text.trim(),
        'driveDate': driveDateStr,
        'date': driveDateStr,
        'registrationDeadline': deadlineStr,
        'status': 'active', // FIXED: Map to lowercase backend active status
        'eligibleBranches': branchIds, // Send MongoDB ObjectIds instead of names
        'branches': branchIds,
      };

      if (_ctcController.text.trim().isNotEmpty) {
        payload['CTC'] = _ctcController.text.trim();
        payload['package'] = _ctcController.text.trim();
        payload['salary'] = _ctcController.text.trim();
      }
      if (_cgpaController.text.trim().isNotEmpty) {
        payload['minCgpa'] = double.tryParse(_cgpaController.text.trim()) ?? 0.0;
        payload['cgpaCriteria'] = double.tryParse(_cgpaController.text.trim()) ?? 0.0;
      }
      if (_jdFilePath != null && _jdFilePath!.isNotEmpty) {
        payload['jdUrl'] = _jdFilePath;
      }

      print('🚀 Submitting drive creation with payload: $payload');
      print('👉 Status value sent: active');
      print('👉 Mapped Branch IDs sent: $branchIds');

      final drivesViewModel = context.read<DrivesViewModel>();

      // ── Call backend ───────────────────────────────────────────────────────
      final errorResult = await drivesViewModel.createDrive(payload);

      if (mounted) {
        if (errorResult == null) {
          _showSuccessSnackBar('✅ Drive created successfully!');
          Navigator.pop(context);
        } else {
          // Backend call failed — no local insertion or fake success!
          print('❌ Backend create failed: $errorResult');
          _showErrorSnackBar('Failed to create drive: $errorResult');
        }
      }
    } catch (e) {
      print('💥 _submitForm exception: $e');
      if (mounted) _showErrorSnackBar('Failed to create drive: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Drive',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A2E1A), Color(0xFF061A14)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00C853).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🚀',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Placement Drive',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create and manage recruitment opportunities for students.',
                          style: TextStyle(
                            color: Color(0xFF8A9E94),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Company Details
            FormSectionCard(title: 'Company Details', children: [
              FormTextField(
                controller: _companyController,
                label: 'Company Name',
                placeholder: 'e.g. Google, Microsoft',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Company name is required' : null,
              ),
              const SizedBox(height: 12),
              FormTextField(
                controller: _roleController,
                label: 'Role / Position',
                placeholder: 'e.g. Software Engineer',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Role is required' : null,
              ),
              const SizedBox(height: 12),
              FormTextField(
                controller: _ctcController,
                label: 'CTC (LPA)',
                placeholder: 'e.g. 12',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              FormTextField(
                controller: _cgpaController,
                label: 'CGPA Criteria',
                placeholder: 'e.g. 7.5',
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 20),

            // Schedule
            FormSectionCard(title: 'Schedule', children: [
              DatePickerField(
                label: 'Drive Date',
                selectedDate: _driveDate,
                onTap: () => _selectDate(isDriveDate: true),
              ),
              const SizedBox(height: 12),
              DatePickerField(
                label: 'Registration Deadline',
                selectedDate: _registrationDeadline,
                onTap: () => _selectDate(isDriveDate: false),
              ),
            ]),
            const SizedBox(height: 20),

            // Eligible Branches
            FormSectionCard(title: 'Eligible Branches', children: [
              _isLoadingDepartments
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C853),
                        ),
                      ),
                    )
                  : _departments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _departmentsError != null
                                ? '⚠️ Error loading branches: $_departmentsError'
                                : 'No departments registered for your college.',
                            style: const TextStyle(
                              color: Color(0xFF8A9E94),
                              fontSize: 13,
                            ),
                          ),
                        )
                      : BranchSelectionChips(
                          availableBranches: _departments
                              .map((dept) => dept.code ?? dept.name)
                              .toList(),
                          selectedBranches: _selectedBranches,
                          onToggleBranch: _toggleBranch,
                        ),
            ]),
            const SizedBox(height: 20),

            // JD Upload
            JDUploadWidget(jdFilePath: _jdFilePath, onPick: _onJDPick),
            const SizedBox(height: 30),

            // Submit Button
            BottomCTAButton(
              text: 'Create Drive',
              isLoading: _isSubmitting,
              onPressed: _submitForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
