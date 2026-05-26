import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/employee_model.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/faculty_item.dart';

class FacultyRegistrySection extends StatefulWidget {
  final List<Employee> faculty;
  final int totalMembers;
  const FacultyRegistrySection({Key? key, required this.faculty, required this.totalMembers}) : super(key: key);

  @override
  _FacultyRegistrySectionState createState() => _FacultyRegistrySectionState();
}

class _FacultyRegistrySectionState extends State<FacultyRegistrySection> {
  String _searchQuery = '';

  List<Employee> get _filtered {
    if (_searchQuery.isEmpty) return widget.faculty;
    return widget.faculty.where((e) => e.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('👥 FACULTY REGISTRY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${widget.totalMembers} Members', style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search faculty registry... ',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {},
              child: const Text('APPLY'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_filtered.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('NO FACULTY MEMBERS FOUND', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (_, index) => FacultyItem(employee: _filtered[index]),
          ),
      ],
    );
  }
}
