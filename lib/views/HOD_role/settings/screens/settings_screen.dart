import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/HOD_viewmodel/settings_view_model.dart';

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
    _vm.fetchUser();
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
                        child: Text('Failed to load settings',
                            style: TextStyle(color: Colors.white54)))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3D34),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.green.withAlpha(80)),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.deepPurple,
                                    child: Text(vm.user!.initials,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(vm.user!.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${vm.user!.role} · ${vm.user!.college}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12)),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withAlpha(51),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.green.withAlpha(80)),
                                    ),
                                    child: const Text('Admin Access',
                                        style: TextStyle(
                                            color: Colors.purple, fontSize: 12)),
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
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
