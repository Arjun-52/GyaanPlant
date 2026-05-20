import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';
import '../../../../viewmodels/HOD_viewmodel/settings_view_model.dart';
import '../../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SettingsViewModel();

    // Wrap API call in addPostFrameCallback to prevent setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vm.fetchUser();
      }
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061A14),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.user == null
                ? const Center(
                    child: Text(
                      'Failed to load settings',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final shouldLogout = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF061A14),
                                    title: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to logout?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Logout'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldLogout == true) {
                                  await LocalStorageService.clearToken();
                                  if (context.mounted) context.go('/');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.logout, color: Colors.red, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3D34),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withAlpha(80),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  vm.user!.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                vm.user!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${vm.user!.role} · ${vm.user!.college}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withAlpha(51),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.withAlpha(80),
                                  ),
                                ),
                                child: const Text(
                                  'Admin Access',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _tile('College Profile & Branding'),
                        _tile('Syllabus Mapping Config'),
                        _tile('Report Templates'),
                        _tile('Staff Access Management'),
                        _tile('GyaanPlant MOU Details'),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _tile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
