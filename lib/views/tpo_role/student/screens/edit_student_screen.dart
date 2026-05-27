import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;

  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _rollController;
  late TextEditingController _cgpaController;
  late TextEditingController _careerController;
  late String _branch;
  late String _year;
  late String _status;
  bool _isSaving = false;

  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'IT'];
  final List<String> _years = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _statuses = ['MNC Ready', 'Average', 'At Risk'];

  String _normalizeBranch(String branch) {
    switch (branch.trim().toUpperCase()) {
      case 'MECH':
        return 'Mechanical';
      case 'CIVIL':
        return 'Civil';
      default:
        return branch.trim();
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    _rollController = TextEditingController(text: widget.student.rollNo);
    _cgpaController = TextEditingController(text: widget.student.cgpa.toString());
    _careerController = TextEditingController(text: widget.student.careerPath);
    
    final normalizedBranch = _normalizeBranch(widget.student.branch);
    _branch = _branches.contains(normalizedBranch) ? normalizedBranch : 'CSE';
    _year = _years.contains(widget.student.year) ? widget.student.year : 'Year 3';
    _status = _statuses.contains(widget.student.status) ? widget.student.status : 'Average';
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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final rollNo = _rollController.text.trim();
    final cgpa = double.tryParse(_cgpaController.text.trim()) ?? 0.0;
    final careerPath = _careerController.text.trim();
    final yearNum = int.tryParse(_year.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

    final payload = {
      'name': name,
      'email': email,
      'branch': _branch,
      'year': yearNum,
      'rollNo': rollNo,
      'cgpa': cgpa,
      'careerPath': careerPath,
    };

    print('Student ID: ${widget.student.id}');
    print('Payload: $payload');

    setState(() {
      _isSaving = true;
    });

    try {
      final studentVm = context.read<StudentViewModel>();
      await studentVm.updateStudent(
        currentStudent: widget.student,
        id: widget.student.id,
        name: name,
        email: email,
        branch: _branch,
        year: yearNum,
        rollNo: rollNo,
        cgpa: cgpa,
        careerPath: careerPath,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Color(0xFF00C853),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
          'Edit Profile',
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
                    child: _buildDropdown('Branch', _branch, _branches, (val) {
                      setState(() => _branch = val!);
                    }),
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
                      onPressed: _isSaving ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _isSaving ? 'Saving...' : 'Save Changes',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: const TextStyle(color: Colors.white)),
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
