import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_notification_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/notification/screens/tpo_notification_screen.dart';
import 'package:gyaanplant/views/HOD_role/naac/screens/naac_screen.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:gyaanplant/core/utils/greeting_helper.dart';

class TPODashboard extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onCreateDriveTap;
  final VoidCallback? onManageStudentsTap;
  final VoidCallback? onGenerateReportsTap;
  const TPODashboard({
    super.key,
    this.onProfileTap,
    this.onCreateDriveTap,
    this.onManageStudentsTap,
    this.onGenerateReportsTap,
  });

  @override
  State<TPODashboard> createState() => _TPODashboardState();
}

class _TPODashboardState extends State<TPODashboard> with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late AnimationController _pulseCtrl;

  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    print("🖥️ TPO Dashboard initState() called");

    // Staggered Entrance Animations
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnims = List.generate(8, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(8, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print("🖥️ Calling TPO Dashboard initialize() from initState");
        context.read<TpoDashboardViewModel>().initialize();
        if (mounted) {
          _staggerCtrl.forward(from: 0.0);
        }
        context.read<TpoNotificationViewModel>().fetchNotifications(reset: true);
      }
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // Background ambient glowing gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF02120F), Color(0xFF020907)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0A00E676),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 350,
                height: 350,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0700FFA3),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Consumer<TpoDashboardViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return _buildSkeletonLoader();
                }

                if (viewModel.hasError) {
                  return _error(viewModel);
                }

                if (!viewModel.hasData) {
                  return _empty();
                }

                // Make sure staggered animation triggers on data load
                if (!_staggerCtrl.isAnimating && _staggerCtrl.value == 0.0) {
                  _staggerCtrl.forward();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      viewModel.refreshDashboardData(),
                      context.read<TpoNotificationViewModel>().fetchNotifications(reset: true),
                    ]);
                    if (mounted) {
                      _staggerCtrl.forward(from: 0.0);
                    }
                  },
                  color: const Color(0xFF00FFA3),
                  backgroundColor: const Color(0xFF020B08),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. HERO HEADER SECTION
                        FadeTransition(
                          opacity: _fadeAnims[0],
                          child: SlideTransition(
                            position: _slideAnims[0],
                            child: _buildHeroHeader(viewModel),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. STATISTICS METRIC GRID (2x2)
                        FadeTransition(
                          opacity: _fadeAnims[1],
                          child: SlideTransition(
                            position: _slideAnims[1],
                            child: _buildStatsGrid(viewModel),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 3. QUICK ACTIONS
                        FadeTransition(
                          opacity: _fadeAnims[2],
                          child: SlideTransition(
                            position: _slideAnims[2],
                            child: _buildQuickActions(),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 4. UPCOMING DRIVES SECTION
                        FadeTransition(
                          opacity: _fadeAnims[3],
                          child: SlideTransition(
                            position: _slideAnims[3],
                            child: _buildUpcomingDrivesSection(viewModel),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 5. PLACEMENT ANALYTICS PREVIEW
                        FadeTransition(
                          opacity: _fadeAnims[4],
                          child: SlideTransition(
                            position: _slideAnims[4],
                            child: _buildAnalyticsSection(viewModel),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBlock(height: 100, radius: 24),
          const SizedBox(height: 20),
          _skeletonBlock(height: 200, radius: 24),
          const SizedBox(height: 20),
          _skeletonBlock(height: 110, radius: 20),
          const SizedBox(height: 20),
          _skeletonBlock(height: 160, radius: 22),
        ],
      ),
    );
  }

  Widget _skeletonBlock({required double height, required double radius}) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                colors: [Color(0xFF0C241E), Color(0xFF02100C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.05),
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(TpoDashboardViewModel vm) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.user;
    final String greetingStr = GreetingHelper.getGreeting(user?.name, user?.role ?? 'TPO');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.45),
            const Color(0xFF030D0A).withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingStr,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage placements, track readiness, and drive student success.',
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              // Notification Trigger
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
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
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
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
              const SizedBox(width: 10),
              // Profile Avatar
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFA3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 18,
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
      ),
    );
  }

  Widget _buildStatsGrid(TpoDashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _PremiumStatCard(
                emoji: '📚',
                title: 'Total Students',
                value: vm.totalStudents.toString(),
                subtitle: 'From college roster',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PremiumStatCard(
                emoji: '🚀',
                title: 'Active Drives',
                value: vm.activeDrives.toString(),
                subtitle: '${vm.closingSoon} closing soon',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PremiumStatCard(
                emoji: '📈',
                title: 'Placement Rate',
                value: vm.placementRateText,
                subtitle: '${vm.studentsPlaced} placed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PremiumStatCard(
                emoji: '💼',
                title: 'Weekly Offers',
                value: vm.weeklyOffers.toString(),
                subtitle: vm.weeklyOffersText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildActionCard(
              title: 'Create Drive',
              icon: Icons.add_circle_outline_rounded,
              color: const Color(0xFF00FFA3),
              onTap: () {
                if (widget.onCreateDriveTap != null) {
                  widget.onCreateDriveTap!();
                }
              },
            ),
            _buildActionCard(
              title: 'Manage Students',
              icon: Icons.school_outlined,
              color: const Color(0xFF00E5FF),
              onTap: () {
                if (widget.onManageStudentsTap != null) {
                  widget.onManageStudentsTap!();
                }
              },
            ),
            _buildActionCard(
              title: 'Generate Reports',
              icon: Icons.analytics_outlined,
              color: const Color(0xFFFFD600),
              onTap: () {
                if (widget.onGenerateReportsTap != null) {
                  widget.onGenerateReportsTap!();
                }
              },
            ),
            _buildActionCard(
              title: 'Notifications',
              icon: Icons.campaign_outlined,
              color: const Color(0xFFFF3D00),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TpoNotificationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0C241B).withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDrivesSection(TpoDashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Drives',
          style: TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (vm.hasUpcomingDrives)
          Column(
            children: vm.drives.map((drive) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDriveCard(drive),
              );
            }).toList(),
          )
        else
          _buildEmptyDrivesCard(),
      ],
    );
  }

  Widget _buildDriveCard(dynamic drive) {
    // Redesign drive card with premium glass styling
    final String company = drive.company ?? 'Unknown Corp';
    final String date = drive.driveDate != null ? drive.driveDate.toString() : 'TBD';
    final int eligibleCount = drive.eligibleCount ?? 0;
    final int registeredCount = drive.registeredCount ?? 0;
    final String status = drive.status ?? 'Active';

    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3B2E).withValues(alpha: 0.35),
            const Color(0xFF030D0A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.02),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  company,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF00FFA3),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Color(0xFF00FFA3), size: 14),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Eligible', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    const SizedBox(height: 2),
                    Text(
                      '$eligibleCount students',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Registered', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    const SizedBox(height: 2),
                    Text(
                      '$registeredCount applied',
                      style: const TextStyle(color: Color(0xFF00FFA3), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDrivesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0C241B).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF00FFA3),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '📅 No Upcoming Drives',
            style: TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are currently no placement drives scheduled.',
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(TpoDashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Placement Growth',
          style: TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: const Color(0xFF0C241B).withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Readiness',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Readiness profile score across candidates',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '78.4%',
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      color: Color(0xFF00FFA3),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.784,
                  minHeight: 8,
                  color: Color(0xFF00FFA3),
                  backgroundColor: Color(0xFF0A1F18),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Top Performing Departments',
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildDepartmentProgressRow('Computer Science & Engineering', 0.94),
              const SizedBox(height: 8),
              _buildDepartmentProgressRow('Information Technology', 0.88),
              const SizedBox(height: 8),
              _buildDepartmentProgressRow('Electronics & Communication', 0.76),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentProgressRow(String name, double percentage) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: const TextStyle(color: Colors.white54, fontSize: 11, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 5,
              color: const Color(0xFF00FFA3),
              backgroundColor: const Color(0xFF0A1F18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _error(TpoDashboardViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                vm.initialize();
                if (mounted) _staggerCtrl.forward(from: 0.0);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dashboard_rounded,
            color: Colors.white38,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No placement data available',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _PremiumStatCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;

  const _PremiumStatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F3B2E).withValues(alpha: 0.35),
                const Color(0xFF030D0A).withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF00FFA3).withValues(
                alpha: _isHovered ? 0.35 : 0.15,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFA3).withValues(
                  alpha: _isHovered ? 0.08 : 0.02,
                ),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: const TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFA3),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontFamily: 'Gilroy-Semibold',
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}