import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';
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
      if (mounted) context.read<TpoDashboardViewModel>().initialize();
    });
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    final d = DateTime.tryParse(date);
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: Consumer<TpoDashboardViewModel>(
        builder: (context, viewModel, _) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning, TPO 👋',
                              style: TextStyle(color: Colors.white54),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'GRIET Hyderabad',
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
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
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
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
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
    );
  }

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  Widget _error(TpoDashboardViewModel vm) {
    return Center(
      child: Column(
        children: [
          Text(
            vm.errorMessage ?? 'Something went wrong',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: vm.retryFetch, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _success(TpoDashboardViewModel vm) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardStatCard(
              title: 'Total Students',
              value: vm.summary.totalStudents.toString(),
              subtitle: 'From API',
            ),
            DashboardStatCard(
              title: 'Active Drives',
              value: vm.summary.activeDrives.toString(),
              subtitle: '${vm.summary.closingSoon} closing soon',
            ),
            DashboardStatCard(
              title: 'Placement Rate',
              value: vm.placementRateText,
              subtitle: '${vm.summary.studentsPlaced} placed',
            ),
            DashboardStatCard(
              title: 'Weekly Offers',
              value: vm.summary.weeklyOffers.toString(),
              subtitle: vm.weeklyOffersText,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Upcoming Drives',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (vm.hasUpcomingDrives) ...[
          ...vm.upcomingDrives.map((drive) {
            return Card(
              color: Colors.white10,
              child: ListTile(
                title: Text(
                  drive.company ?? 'Company',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${drive.role ?? ''} • ${_formatDate(drive.driveDate)}',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  '${drive.eligibleCount ?? 0} eligible',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            );
          }),
        ] else ...[
          const Card(
            color: Colors.white10,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No upcoming drives',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No dashboard data available',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
