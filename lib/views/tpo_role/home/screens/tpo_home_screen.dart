import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/dashboard_stat_card.dart';
import 'package:provider/provider.dart';

class TPODashboard extends StatefulWidget {
  const TPODashboard({super.key});

  @override
  State<TPODashboard> createState() => _TPODashboardState();
}

class _TPODashboardState extends State<TPODashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TpoDashboardViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),

      body: Consumer<TpoDashboardViewModel>(
        builder: (context, viewModel, _) {
          print("📊 UI STATE:");
          print("isLoading: ${viewModel.isLoading}");
          print("hasData: ${viewModel.hasData}");
          print("error: ${viewModel.errorMessage}");

          return RefreshIndicator(
            onRefresh: viewModel.refreshDashboardData,
            color: Colors.green,

            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good morning, TPO 👋",
                              style: TextStyle(color: Colors.white54),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "GRIET Hyderabad",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: () async {
                            await LocalStorageService.clearToken();
                            if (context.mounted) context.go('/');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout, color: Colors.red),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STATES
                    if (viewModel.isLoading)
                      _loading()
                    else if (viewModel.hasError)
                      _error(viewModel)
                    else if (viewModel.hasData)
                      _success(viewModel)
                    else
                      _empty(),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: const TpoBottomNav(currentIndex: 0),
    );
  }

  /// 🔄 LOADING
  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  /// ❌ ERROR
  Widget _error(TpoDashboardViewModel vm) {
    return Center(
      child: Column(
        children: [
          Text(
            vm.errorMessage ?? "Something went wrong",
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: vm.retryFetch, child: const Text("Retry")),
        ],
      ),
    );
  }

  /// 📊 SUCCESS (MAIN UI)
  Widget _success(TpoDashboardViewModel vm) {
    return Column(
      children: [
        /// TOP CARDS
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardStatCard(
              title: "Total Students",
              value: vm.summary.totalStudents.toString(),
              subtitle: "From API",
            ),

            DashboardStatCard(
              title: "Active Drives",
              value: vm.summary.activeDrives.toString(),
              subtitle: "${vm.summary.closingSoon} closing soon",
            ),

            DashboardStatCard(
              title: "Placement Rate",
              value: vm.placementRateText,
              subtitle: "${vm.summary.studentsPlaced} placed",
            ),

            DashboardStatCard(
              title: "Weekly Offers",
              value: vm.summary.weeklyOffers.toString(),
              subtitle: vm.weeklyOffersText,
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// UPCOMING DRIVES (FROM API)
        if (vm.hasUpcomingDrives) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Upcoming Drives",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ...vm.upcomingDrives.map((drive) {
            return Card(
              color: Colors.white10,
              child: ListTile(
                title: Text(
                  drive.company ?? "Company",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${drive.role ?? ""} • ${drive.date ?? ""}",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  "${drive.registered ?? 0}/${drive.eligible ?? 0}",
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            );
          }).toList(),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  /// 📭 EMPTY
  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          "No dashboard data available",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
