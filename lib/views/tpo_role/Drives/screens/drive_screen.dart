import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widegts/drive_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';

class DrivesScreen extends StatelessWidget {
  const DrivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrivesViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<DrivesViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    const Text(
                      "Placement Drives 📅",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CREATE BUTTON
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "+ Create New Drive",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LIST
                    Expanded(
                      child: ListView.separated(
                        itemCount: vm?.drives.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => DriveCard(drive: vm!.drives[i]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const TpoBottomNav(currentIndex: 2),
      ),
    );
  }
}
