import 'package:flutter/material.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/custom_card.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/info_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/analytics_view_model.dart';
import 'package:gyaanplant/core/common_widgets/hod_bottom_nav.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel()..fetchAnalytics(),
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
                            "Analytics 📊",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 🔥 Monthly Active Students
                          CustomCard(
                            title: "Monthly Active Students",
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(6, (index) {
                                final data =
                                    vm.data?.monthlyActive ??
                                    [10, 20, 30, 40, 50, 60];

                                return Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: data[index].toDouble(),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: index == data.length - 1
                                              ? Colors.green
                                              : Colors.white12,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        [
                                          "Oct",
                                          "Nov",
                                          "Dec",
                                          "Jan",
                                          "Feb",
                                          "Mar",
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

                          /// Placement Rate
                          CustomCard(
                            title: "Placement Rate by Year",
                            child: Row(
                              children: List.generate(4, (index) {
                                final rates =
                                    vm.data?.placementRates ?? [74, 74, 74, 87];

                                return Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: rates[index].toDouble(),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: index == 3
                                              ? Colors.green
                                              : Colors.white12,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ["2022", "2023", "2024", "2025"][index],
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${rates[index]}%",
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

                          /// 🔥 INFO CARDS (USING YOUR WIDGET)
                          InfoCard(
                            icon: Icons.people,
                            title: "Students Active This Month",
                            value: vm.data?.activeStudents.toString() ?? "0",
                            badge: "+12%",
                          ),

                          InfoCard(
                            icon: Icons.timer,
                            title: "Avg Hours / Student",
                            value: "${vm.data?.avgHours ?? 0} hrs",
                            badge: "+2.1 hrs",
                          ),

                          InfoCard(
                            icon: Icons.track_changes,
                            title: "Avg Readiness Score",
                            value: "${vm.data?.readinessScore ?? 0}/100",
                            badge: "+4 pts",
                          ),

                          InfoCard(
                            icon: Icons.description,
                            title: "Certificates Issued",
                            value: vm.data?.certificates.toString() ?? "0",
                            badge: "+320 this month",
                          ),
                        ],
                      ),
                    ),
                  ),

            bottomNavigationBar: const HODBottomNav(currentIndex: 2),
          );
        },
      ),
    );
  }
}
