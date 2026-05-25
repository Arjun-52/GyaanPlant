import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_notification_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/dashboard_stat_card.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/tpo_dashboard_shimmer.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/upcoming_drive_card.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/empty_drives_card.dart';
import 'package:gyaanplant/views/tpo_role/notification/screens/tpo_notification_screen.dart';
import 'package:provider/provider.dart';

class TPODashboard extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const TPODashboard({super.key, this.onProfileTap});

  @override
  State<TPODashboard> createState() => _TPODashboardState();
}

class _TPODashboardState extends State<TPODashboard> {
  @override
  void initState() {
    super.initState();
    print("🖥️ TPO Dashboard initState() called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print("🖥️ Calling TPO Dashboard initialize() from initState");
        context.read<TpoDashboardViewModel>().initialize();
        context.read<TpoNotificationViewModel>().fetchNotifications(reset: true);
      } else {
        print("❌ Widget not mounted, skipping initialize()");
      }
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
            onRefresh: () async {
              await Future.wait([
                viewModel.refreshDashboardData(),
                context.read<TpoNotificationViewModel>().fetchNotifications(reset: true),
              ]);
            },
            color: Colors.green,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<TpoDashboardViewModel>(
                      builder: (context, vm, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Good morning, TPO 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                // Premium Notification Bell Icon
                                Consumer<TpoNotificationViewModel>(
                                  builder: (context, notifVm, _) {
                                    final int unreadCount = notifVm.unreadCount;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const TpoNotificationScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            const Icon(
                                              Icons.notifications_none_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            if (unreadCount > 0)
                                              Positioned(
                                                right: -4,
                                                top: -4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 16,
                                                    minHeight: 16,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Profile Avatar
                                GestureDetector(
                                  onTap: widget.onProfileTap,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF00C853),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00C853).withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(0xFF0C2D24),
                                      backgroundImage: NetworkImage(
                                        'https://img.icons8.com/color/96/user-male-circle--v1.png',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    if (viewModel.isLoading)
                      _loading()
                    else if (viewModel.hasError)
                      _error(viewModel)
                    else if (!viewModel.isLoading)
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
    return const TpoDashboardShimmer();
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              value: vm.totalStudents.toString(),
              subtitle: 'From API',
            ),
            DashboardStatCard(
              title: 'Active Drives',
              value: vm.activeDrives.toString(),
              subtitle: '${vm.closingSoon} closing soon',
            ),
            DashboardStatCard(
              title: 'Placement Rate',
              value: vm.placementRateText,
              subtitle: '${vm.studentsPlaced} placed',
            ),
            DashboardStatCard(
              title: 'Weekly Offers',
              value: vm.weeklyOffers.toString(),
              subtitle: vm.weeklyOffersText,
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Upcoming Drives',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (vm.hasUpcomingDrives)
          SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vm.drives.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return UpcomingDriveCard(drive: vm.drives[index]);
              },
            ),
          )
        else
          const EmptyDrivesCard(),
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