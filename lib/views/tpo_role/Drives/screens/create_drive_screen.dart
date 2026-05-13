import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/form_section_card.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/form_text_field.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/date_picker_field.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/branch_selection_chips.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/jd_upload_widget.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/bottom_cta_button.dart';
import 'package:gyaanplant/views/tpo_role/Drives/services/file_upload_service.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/drives_viewmodel.dart';

class CreateDriveScreen extends StatefulWidget {
  const CreateDriveScreen({super.key});

  @override
  State<CreateDriveScreen> createState() => _CreateDriveScreenState();
}

class _CreateDriveScreenState extends State<CreateDriveScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _ctcController = TextEditingController();
  final _cgpaController = TextEditingController();

  // Date variables
  DateTime? _driveDate;
  DateTime? _registrationDeadline;

  // Multi-select branches
  final List<String> _availableBranches = [
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'AIML',
    'AIDS',
    'CSBS',
  ];
  Set<String> _selectedBranches = <String>{};

  // File upload
  String? _jdFilePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _ctcController.dispose();
    _cgpaController.dispose();
    super.dispose();
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
              surface: Color(0xFF0A2E1A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF061A14),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00C853),
              ),
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

  Future<void> _pickJDFile() async {
    try {
      final String? filePath = await FileUploadService.pickJDFile();

      if (filePath != null) {
        setState(() {
          _jdFilePath = filePath;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick JD file: $e');
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
      // Create Drive object from form data
      final newDrive = Drive(
        company: _companyController.text.trim(),
        role: 'TPO', // This is a TPO-created drive
        date: _driveDate != null
            ? '${_driveDate!.day}/${_driveDate!.month}/${_driveDate!.year}'
            : '',
        eligible: 0, // Will be updated when students register
        registered: 0, // Will be updated when students register
        pending: 0, // Will be updated when students register
        status: 'Active',
      );

      // Get the DrivesViewModel instance and add the new drive
      final drivesViewModel = context.read<DrivesViewModel>();
      await drivesViewModel.addDrive(newDrive);

      if (mounted) {
        _showSuccessSnackBar('Drive created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create drive: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSectionCard(
                      children: [
                        FormTextField(
                          controller: _companyController,
                          label: 'Company Name',
                          placeholder: 'e.g. Google, Microsoft',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormTextField(
                          controller: _roleController,
                          label: 'Target Role',
                          placeholder: 'e.g. Software Engineer',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter target role';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormTextField(
                          controller: _ctcController,
                          label: 'CTC Package',
                          placeholder: 'e.g. 12 LPA',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter CTC package';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    FormSectionCard(
                      children: [
                        DatePickerField(
                          label: 'Drive Schedule Date',
                          selectedDate: _driveDate,
                          onTap: () => _selectDate(isDriveDate: true),
                        ),
                        const SizedBox(height: 16),
                        DatePickerField(
                          label: 'Registration Deadline',
                          selectedDate: _registrationDeadline,
                          onTap: () => _selectDate(isDriveDate: false),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    FormSectionCard(
                      children: [
                        BranchSelectionChips(
                          availableBranches: _availableBranches,
                          selectedBranches: _selectedBranches,
                          onToggleBranch: _toggleBranch,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    FormSectionCard(
                      children: [
                        FormTextField(
                          controller: _cgpaController,
                          label: 'Minimum CGPA',
                          placeholder: 'e.g. 7.5',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter minimum CGPA';
                            }
                            final cgpa = double.tryParse(value);
                            if (cgpa == null || cgpa < 0 || cgpa > 10) {
                              return 'Please enter valid CGPA (0-10)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        JDUploadWidget(
                          jdFilePath: _jdFilePath,
                          onPickFile: _pickJDFile,
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Sticky bottom CTA
          BottomCTAButton(
            text: 'Create Drive',
            isLoading: _isSubmitting,
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
