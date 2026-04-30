import 'package:flutter/material.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/custom_card.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/info_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/analytics_view_model.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';

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

    // Initialize ViewModel directly in initState (no async delay)
    final dashboardVM = context.read<HodDashboardViewModel>();
    _vm = AnalyticsViewModel(dashboardVM);
    _vm.generateAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<AnalyticsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061A14),
            body: SafeArea(
              child: Padding(
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

                    // ===== MONTHLY CHART =====
                    CustomCard(
                      title: 'Monthly Active Students',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(6, (index) {
                          final data = vm.monthlyActive;
                          if (index >= data.length) {
                            return const Expanded(child: SizedBox());
                          }

                          return Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: (data[index] / 20)
                                      .clamp(10, 120)
                                      .toDouble(),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == data.length - 1
                                        ? Colors.green
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  [
                                    'Oct',
                                    'Nov',
                                    'Dec',
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                  ][index],
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== PLACEMENT CHART =====
                    CustomCard(
                      title: 'Placement Rate by Year',
                      child: Row(
                        children: List.generate(4, (index) {
                          final rates = vm.placementRates;
                          if (index >= rates.length) {
                            return const Expanded(child: SizedBox());
                          }

                          return Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: (rates[index] * 1.2)
                                      .clamp(20, 120)
                                      .toDouble(),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == 3
                                        ? Colors.green
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ['2022', '2023', '2024', '2025'][index],
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${rates[index]}%',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== INFO CARDS =====
                    InfoCard(
                      icon: Icons.people,
                      title: 'Students Active This Month',
                      value: vm.activeStudents.toString(),
                      badge: '+8%',
                    ),
                    InfoCard(
                      icon: Icons.timer,
                      title: 'Avg Hours / Student',
                      value: '${vm.avgHours} hrs',
                      badge: '+2.1 hrs',
                    ),
                    InfoCard(
                      icon: Icons.track_changes,
                      title: 'Avg Readiness Score',
                      value: '${vm.readinessScore}/100',
                      badge: '+4 pts',
                    ),
                    InfoCard(
                      icon: Icons.description,
                      title: 'Certificates Issued',
                      value: vm.certificates.toString(),
                      badge: '+320 this month',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
