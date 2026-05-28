import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:provider/provider.dart';

class BranchOption {
  final String id;
  final String name;

  BranchOption({required this.id, required this.name});
}

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _careerController = TextEditingController();
  
  String _branch = 'CSE';
  String _branchId = '';
  String _year = 'Year 3';
  String _status = 'Average';
  bool _isBranchLoading = true;
  bool _isSaving = false;
  String? _branchLoadError;

  final List<BranchOption> _branchOptions = [];
  final List<String> _years = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _statuses = ['MNC Ready', 'Average', 'At Risk'];

  @override
  void initState() {
    super.initState();
    _loadBranchOptions();
  }

  Future<void> _loadBranchOptions() async {
    setState(() {
      _isBranchLoading = true;
      _branchLoadError = null;
    });

    try {
      final result = await ApiService().hod.getDepartments();
      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        final options = result.data!
            .map((dept) => BranchOption(id: dept.id, name: dept.name))
            .toList();

        final selected = options.firstWhere(
          (option) => option.name == _branch,
          orElse: () => options.first,
        );

        setState(() {
          _branchOptions.clear();
          _branchOptions.addAll(options);
          _branch = selected.name;
          _branchId = selected.id;
        });
      } else {
        throw Exception(result.error?.message ?? 'No branch data available');
      }
    } catch (e) {
      setState(() {
        _branchLoadError = e.toString();
      });
    } finally {
      setState(() {
        _isBranchLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _cgpaController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final rollNo = _rollController.text.trim();
      final cgpa = double.tryParse(_cgpaController.text) ?? 8.0;
      final careerPath = _careerController.text.trim().isEmpty ? "Software Engineer" : _careerController.text.trim();

      if (_branchId.isEmpty) {
        setState(() {
          _isSaving = false;
        });
        throw Exception('Branch data not loaded. Please try again.');
      }

      // Show professional glassmorphic loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D34),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853))),
                SizedBox(height: 16),
                Text(
                  'Onboarding Student...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        await context.read<StudentViewModel>().onboardStudent(
          name: name,
          email: email,
          branch: _branchId,
          year: _year,
          rollNo: rollNo,
          cgpa: cgpa,
          careerPath: careerPath,
        );

        if (mounted) {
          // Pop loading dialog
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student onboarded successfully!'),
              backgroundColor: Color(0xFF00C853),
            ),
          );
          // Go back to the student list screen
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          // Pop loading dialog
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student created successfully'),
              backgroundColor: Colors.greenAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Student',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField('Full Name', _nameController, Icons.person_rounded),
              const SizedBox(height: 16),
              _buildTextField('Email Address', _emailController, Icons.email_rounded, isEmail: true),
              const SizedBox(height: 25),

              const Text(
                'Academic Information',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField('Roll Number', _rollController, Icons.badge_rounded),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _isBranchLoading
                        ? Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2A22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                            ),
                          )
                        : _branchLoadError != null
                            ? Text(
                                'Branch load failed',
                                style: const TextStyle(color: Colors.redAccent),
                              )
                            : _buildDropdown(
                                'Branch',
                                _branch,
                                _branchOptions.map((option) => option.name).toList(),
                                (val) {
                                  if (val == null) return;
                                  final selected = _branchOptions.firstWhere(
                                    (option) => option.name == val,
                                    orElse: () => BranchOption(id: '', name: val),
                                  );
                                  setState(() {
                                    _branch = selected.name;
                                    _branchId = selected.id;
                                  });
                                },
                              ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown('Year', _year, _years, (val) {
                      setState(() => _year = val!);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField('CGPA', _cgpaController, Icons.analytics_rounded, isNumber: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown('Status', _status, _statuses, (val) {
                      setState(() => _status = val!);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              const Text(
                'Placement Strategy',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField('Target Career Path', _careerController, Icons.work_rounded),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSaving || _isBranchLoading || _branchId.isEmpty) ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Onboard Student',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isEmail = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (isNumber) {
          final n = double.tryParse(value);
          if (n == null || n < 0 || n > 10) {
            return 'Enter CGPA between 0-10';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F2A22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00C853)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      )).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF071E17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF0F2A22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00C853)),
        ),
      ),
    );
  }
}
