import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widegts/drive_card.dart';
import 'create_drive_screen.dart';

class DrivesScreen extends StatefulWidget {
  const DrivesScreen({super.key});

  @override
  State<DrivesScreen> createState() => _DrivesScreenState();
}

class _DrivesScreenState extends State<DrivesScreen> {
  @override
  void initState() {
    super.initState();
    print('🎯 DrivesScreen.initState() called');

    // Wrap API call in addPostFrameCallback to prevent setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔔 Calling DrivesViewModel.fetchDrives() from initState');
        context.read<DrivesViewModel>().fetchDrives();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DrivesViewModel>();
    print(
      '📱 DrivesScreen.build() called - isLoading: ${vm.isLoading}, drives: ${vm.drives.length}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: RefreshIndicator(
        onRefresh: () {
          print('🔄 Refresh triggered for drives');
          return vm.refreshDrives();
        },
        color: Colors.green,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Placement Drives',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateDriveScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+ Create New Drive',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (vm.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (vm.error != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Error: ${vm.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (vm.drives.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No drives available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: vm.drives.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => DriveCard(drive: vm.drives[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
