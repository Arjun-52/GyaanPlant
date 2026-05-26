import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/departments_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/depts/screens/add_college_department_screen.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/department_card.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  late final DepartmentsViewModel _vm;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _vm = DepartmentsViewModel();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.loadDepartments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),
        body: Consumer<DepartmentsViewModel>(
          builder: (context, vm, _) {
            // ── Loading ────────────────────────────────────────────────────
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Error ──────────────────────────────────────────────────────
            if (vm.error != null) {
              return Center(
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // ── Empty (no data at all, before any search) ──────────────────
            if (vm.departments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No Departments Found',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'DEBUG INFO',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loading: ${vm.isLoading}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Error: ${vm.error ?? "None"}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Departments: ${vm.departments.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => vm.debugUserInfo(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('DEBUG USER INFO'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => vm.loadDepartments(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('RELOAD DEPARTMENTS'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final displayed = vm.filteredDepartments;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Row ──────────────────────────────────────────
                    Row(
                      children: [
                        const Text(
                          'Departments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // ── Add College Dept button ─────────────────────────
                        _AddDeptButton(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddCollegeDepartmentScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Search + Apply Row ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: vm.updateQuery,
                            decoration: InputDecoration(
                              hintText: 'Filter units by name or code...',
                              hintStyle:
                                  const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF0F3D34),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF00C853), width: 1.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ── APPLY button ────────────────────────────────────
                        ElevatedButton(
                          onPressed: vm.applyFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'APPLY',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── No Results (after filter applied) ───────────────────
                    if (displayed.isEmpty && vm.searchQuery.isNotEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'NO RESULTS FOUND',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      )

                    // ── Department List ─────────────────────────────────────
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: displayed.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              DepartmentCard(dept: displayed[i]),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── "Add College Dept" rounded black button ─────────────────────────────────────
class _AddDeptButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddDeptButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.add, size: 16),
      label: const Text(
        'Add College Dept',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
