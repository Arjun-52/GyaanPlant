import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/analytics_view_model.dart';
import 'package:gyaanplant/core/common_widgets/HOD_bottom_nav.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AnalyticsViewModel();
    _vm.fetchAnalytics();
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
      child: Consumer<AnalyticsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061A14),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        const Text(
                          'Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _card(
                          title: 'Monthly Active Students',
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(6, (index) {
                              final isLast = index == 5;
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 30 + (index * 10).toDouble(),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: isLast ? Colors.green : Colors.white12,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'][index],
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _card(
                          title: 'Placement Rate by Year',
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: ['2022', '2023', '2024', '2025'].map((year) {
                              final isLast = year == '2025';
                              return Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: isLast ? 70 : 50,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: isLast ? Colors.green : Colors.white12,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(year,
                                        style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      isLast ? '87%' : '74%',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _infoCard(Icons.people, 'Students Active This Month',
                            vm.analytics?.activeStudents.toString() ?? '0',
                            '+${vm.analytics?.growthPercent ?? 0}%'),
                        _infoCard(Icons.timer, 'Avg Hours / Student',
                            '${vm.analytics?.avgHours ?? 0.0} hrs', '+2.1 hrs'),
                        _infoCard(Icons.track_changes, 'Avg Readiness Score',
                            '${vm.analytics?.readinessScore ?? 0}/100', '+4 pts'),
                        _infoCard(Icons.description, 'Certificates Issued',
                            vm.analytics?.certificates.toString() ?? '0', '+320 this month'),
                      ],
                    ),
                  ),
            bottomNavigationBar: const HODBottomNav(currentIndex: 2),
          );
        },
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value, String badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D34),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
