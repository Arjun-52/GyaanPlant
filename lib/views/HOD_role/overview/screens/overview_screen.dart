import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/notification_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/hod_leaderboard_section.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/stat_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/syllabus_card.dart';
import 'package:provider/provider.dart';

class OverViewScreen extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const OverViewScreen({super.key, this.onSettingsTap});

  @override
  State<OverViewScreen> createState() => _OverViewScreenState();
}

class _OverViewScreenState extends State<OverViewScreen> {
  @override
  void initState() {
    super.initState();
    // Dashboard data is automatically loaded by the global provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationViewModel>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<AuthViewModel>().userName ?? 'HOD';
    final nameParts = userName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : nameParts.isNotEmpty
            ? nameParts[0][0].toUpperCase()
            : 'H';

    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: Consumer<HodDashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to Load Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.error!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.loadDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A1F3D), Color(0xFF071E17)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Principal Dashboard',
                              style: TextStyle(color: Colors.white54),
                            ),
                            Row(
                              children: [
                                Consumer<HodDashboardViewModel>(
                                  builder: (context, vm, _) => IconButton(
                                    onPressed: vm.isLoading
                                        ? null
                                        : vm.loadDashboard,
                                    icon: vm.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white70,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.refresh,
                                            color: Colors.white70,
                                            size: 22,
                                          ),
                                    tooltip: 'Refresh Dashboard',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Premium Notification Bell Icon
                                Consumer<NotificationViewModel>(
                                  builder: (context, notifVm, _) {
                                    final int unreadCount = notifVm.unreadCount;
                                    return GestureDetector(
                                      onTap: () {
                                        context.push('/notifications');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
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
                                              size: 20,
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
                                const SizedBox(width: 12),
                                // Profile Avatar
                                GestureDetector(
                                  onTap: widget.onSettingsTap,
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
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFF0C2D24),
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'GRIET Hyderabad',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            HodStatCard(
                              value: vm.totalStudents.toString(),
                              label: 'Total Students',
                              color: Colors.blue,
                            ),
                            HodStatCard(
                              value: vm.departments.toString(),
                              label: 'Departments',
                              color: Colors.blue,
                            ),
                            HodStatCard(
                              value: '${vm.lmsAdoption}%',
                              label: 'LMS Adoption',
                              color: Colors.green,
                            ),
                            HodStatCard(
                              value: vm.naacGrade,
                              label: 'NAAC Grade',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Syllabus Mapping Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SyllabusCard(
                          title: 'CSE — GyaanPlant Courses',
                          subtitle: '8/10 courses mapped to electives',
                          progress: 8,
                        ),
                        const SizedBox(height: 12),
                        const SyllabusCard(
                          title: 'IT — GyaanPlant Courses',
                          subtitle: '6/8 courses mapped to electives',
                          progress: 6,
                        ),
                        const SizedBox(height: 12),
                        const SyllabusCard(
                          title: 'ECE — GyaanPlant Courses',
                          subtitle: '3/10 courses mapped to electives',
                          progress: 2,
                        ),
                        const SizedBox(height: 28),
                        const HodLeaderboardSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
