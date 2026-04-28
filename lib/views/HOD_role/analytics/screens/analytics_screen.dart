import 'package:flutter/material.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/custom_card.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/info_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/analytics_view_model.dart';

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
                : vm.error != null
                ? Center(
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SafeArea(
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
                                        height: data[index].toDouble(),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: index == data.length - 1
                                              ? Colors.green
                                              : Colors.white12,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'][index],
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
                                        height: rates[index].toDouble(),
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: index == 3 ? Colors.green : Colors.white12,
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

                          InfoCard(
                            icon: Icons.people,
                            title: 'Students Active This Month',
                            value: vm.activeStudents.toString(),
                            badge: '+12%',
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

                          const SizedBox(height: 20),

                          if (vm.readiness.isNotEmpty) ...[
                            const Text(
                              'Readiness Analysis',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomCard(
                              title: 'Readiness by Department',
                              child: Column(
                                children: vm.readiness.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item['department'] ?? 'Unknown',
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                        ),
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: (item['score'] ?? 0) / 100,
                                            backgroundColor: Colors.white12,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              (item['score'] ?? 0) >= 70
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${item['score'] ?? 0}%',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (vm.departments.isEmpty && vm.readiness.isEmpty) ...[
                            const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.analytics, size: 50, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text(
                                    'No detailed analytics data available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Check back later for comprehensive analytics',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
