import 'package:flutter/material.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/custom_card.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/info_card.dart';
import 'package:gyaanplant/views/HOD_role/analytics/widegts/analytics_extended.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  Animation<double>? _headerFade;
  Animation<double>? _listFade;
  Animation<Offset>? _listSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _listFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _listSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HodDashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF020B08), // Deep premium black
          body: SafeArea(
            child: Stack(
              children: [
                // ── Ambient Background Glows ─────────────────────────────────
                Positioned(
                  top: -120,
                  right: -80,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.05),
                          blurRadius: 100,
                          spreadRadius: 30,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -100,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.03),
                          blurRadius: 120,
                          spreadRadius: 40,
                        )
                      ],
                    ),
                  ),
                ),

                // ── Main Scrollable Layout ────────────────────────────────────
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // padding for bottom nav
                  children: [
                    // Title section
                    FadeTransition(
                      opacity: _headerFade ?? const AlwaysStoppedAnimation(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analytics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Performance & Placement Insights',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Animating list elements
                    SlideTransition(
                      position: _listSlide ?? const AlwaysStoppedAnimation(Offset.zero),
                      child: FadeTransition(
                        opacity: _listFade ?? const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          children: [
                            // MONTHLY CHART
                            CustomCard(
                              title: 'Monthly Active Students',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(6, (index) {
                                  final overview = vm.data;
                                  if (overview == null) {
                                    return const Expanded(child: SizedBox());
                                  }

                                  final students = overview.totalStudents;
                                  final monthlyData = [
                                    (students * 0.5).toInt(),
                                    (students * 0.6).toInt(),
                                    (students * 0.7).toInt(),
                                    (students * 0.8).toInt(),
                                    (students * 0.9).toInt(),
                                    students,
                                  ];

                                  final isLast = index == monthlyData.length - 1;

                                  return Expanded(
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                          height: (monthlyData[index] / 20)
                                              .clamp(10, 120)
                                              .toDouble(),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isLast
                                                ? const LinearGradient(
                                                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )
                                                : null,
                                            color: isLast ? null : Colors.white.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: isLast
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(0xFF00E676).withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
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
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // PLACEMENT CHART
                            CustomCard(
                              title: 'Placement Rate by Year',
                              child: Row(
                                children: List.generate(4, (index) {
                                  final overview = vm.data;
                                  if (overview == null) {
                                    return const Expanded(child: SizedBox());
                                  }

                                  final completion = overview.lmsAdoption;
                                  final rates = [
                                    (completion - 10).clamp(0, 100),
                                    (completion - 5).clamp(0, 100),
                                    completion.clamp(0, 100),
                                    (completion + 5).clamp(0, 100),
                                  ];

                                  final isLast = index == 3;

                                  return Expanded(
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOut,
                                          height: (rates[index] * 1.2)
                                              .clamp(20, 120)
                                              .toDouble(),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isLast
                                                ? const LinearGradient(
                                                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )
                                                : null,
                                            color: isLast ? null : Colors.white.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: isLast
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(0xFF00E676).withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          ['2022', '2023', '2024', '2025'][index],
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${rates[index]}%',
                                          style: TextStyle(
                                            color: isLast ? const Color(0xFF00E676) : Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // INFO CARDS SECTION
                            InfoCard(
                              icon: Icons.people_outline_rounded,
                              title: 'Students Active This Month',
                              value: vm.data?.totalStudents.toString() ?? "0",
                              badge: '+8%',
                            ),
                            InfoCard(
                              icon: Icons.timer_outlined,
                              title: 'Avg Hours / Student',
                              value: '0.0 hrs',
                              badge: '+2.1 hrs',
                            ),
                            InfoCard(
                              icon: Icons.track_changes_rounded,
                              title: 'Avg Readiness Score',
                              value: '${vm.data?.lmsAdoption ?? 0}/100',
                              badge: '+4 pts',
                            ),
                            InfoCard(
                              icon: Icons.description_outlined,
                              title: 'Certificates Issued',
                              value: '0',
                              badge: '+320 this month',
                            ),
                            const SizedBox(height: 24),

                            // Extended analytics sections
                            const HodAnalyticsExtended(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
