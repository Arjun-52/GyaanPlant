import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/settings_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/settings/widgets/settings_tile.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<SettingsViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    const Text(
                      "Settings ⚙️",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PROFILE CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F3B2E), Color(0xFF0A241D)],
                        ),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blue,
                            child: Text("RP"),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ramesh Prasad",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "TPO • GRIET Hyderabad",
                                  style: TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),

                                    color: const Color(0xFF0F2A22),

                                    border: Border.all(
                                      color: const Color(0xFF1E6FFF),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    "Verified TPO",
                                    style: TextStyle(
                                      color: Color(0xFF4DA3FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SETTINGS LIST
                    Expanded(
                      child: ListView.separated(
                        itemCount: vm.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => SettingsTile(item: vm.items[i]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const TpoBottomNav(currentIndex: 4),
      ),
    );
  }
}
