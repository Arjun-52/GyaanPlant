import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  HOD Analytics Extended Sections - REDESIGNED PREMIUM UX
//  Appended below existing analytics cards.
//  Uses StudentViewModel (already globally provided) for student data.
// ═══════════════════════════════════════════════════════════════════════════

class HodAnalyticsExtended extends StatefulWidget {
  const HodAnalyticsExtended({super.key});

  @override
  State<HodAnalyticsExtended> createState() => _HodAnalyticsExtendedState();
}

class _HodAnalyticsExtendedState extends State<HodAnalyticsExtended> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _appliedQuery = '';
  String _selectedBranch = 'All Branches';
  String _selectedReadiness = 'All Readiness';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final vm = context.read<StudentViewModel>();
        if (!vm.hasData && !vm.isLoading) vm.initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() => _appliedQuery = _searchCtrl.text.trim().toLowerCase());
  }

  List<Student> _filtered(List<Student> all) {
    return all.where((s) {
      final matchQ = _appliedQuery.isEmpty ||
          s.name.toLowerCase().contains(_appliedQuery) ||
          s.rollNo.toLowerCase().contains(_appliedQuery) ||
          s.branch.toLowerCase().contains(_appliedQuery) ||
          s.email.toLowerCase().contains(_appliedQuery);
      final matchBranch = _selectedBranch == 'All Branches' ||
          s.branch.toLowerCase().contains(_selectedBranch.toLowerCase());
      final matchReadiness = _selectedReadiness == 'All Readiness' ||
          s.status == _selectedReadiness;
      return matchQ && matchBranch && matchReadiness;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (context, vm, _) {
        final students = vm.students;
        final filtered = _filtered(students);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Elite Engagement ──────────────────────────────────
            _SectionHeader(
              title: 'Elite Engagement',
              icon: Icons.military_tech_rounded,
              badge: vm.isLoading
                  ? null
                  : '${students.length} Students Tracked',
            ),
            const SizedBox(height: 14),
            if (vm.isLoading)
              _HorizontalShimmer()
            else if (students.isEmpty)
              _EmptyState('No engagement data yet')
            else
              _EliteStudentsList(students: students),

            const SizedBox(height: 28),

            // ── Section 2: CGPA Distribution ─────────────────────────────────
            _SectionHeader(
              title: 'CGPA Distribution',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 14),
            if (vm.isLoading)
              _ShimmerBlock(height: 140)
            else
              _CgpaDistributionCard(students: students),

            const SizedBox(height: 28),

            // ── Section 3: Search + Filters ──────────────────────────────────
            _SectionHeader(
              title: 'Student Readiness Matrix',
              icon: Icons.grid_view_rounded,
            ),
            const SizedBox(height: 14),
            _SearchFilterRow(
              controller: _searchCtrl,
              selectedBranch: _selectedBranch,
              selectedReadiness: _selectedReadiness,
              onBranchChanged: (v) => setState(() => _selectedBranch = v!),
              onReadinessChanged: (v) => setState(() => _selectedReadiness = v!),
              onApply: _applyFilters,
            ),

            const SizedBox(height: 20),

            // ── Section 4: Readiness Matrix Cards ────────────────────────────
            if (vm.isLoading)
              _VerticalShimmer()
            else if (filtered.isEmpty)
              _EmptyState('No students match the selected filters')
            else
              ...filtered.map((s) => _ReadinessCard(student: s)),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? badge;

  const _SectionHeader({required this.title, required this.icon, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
        if (badge != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Section 1: Elite Students horizontal scroll ────────────────────────────────
class _EliteStudentsList extends StatelessWidget {
  final List<Student> students;

  const _EliteStudentsList({required this.students});

  @override
  Widget build(BuildContext context) {
    // Sort by score descending — top engagers first
    final sorted = [...students]..sort((a, b) => b.score.compareTo(a.score));
    final elite = sorted.take(10).toList();

    return SizedBox(
      height: 154,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        itemCount: elite.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _EliteCard(student: elite[i], rank: i + 1),
      ),
    );
  }
}

class _EliteCard extends StatelessWidget {
  final Student student;
  final int rank;

  const _EliteCard({required this.student, required this.rank});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700); // Premium Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Premium Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Premium Bronze
    return const Color(0xFF00E676);
  }

  int get _level => (student.score / 20).ceil().clamp(1, 5);
  int get _points => student.score * 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _rankColor.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _rankColor.withOpacity(0.1),
                child: Text(
                  student.initials,
                  style: TextStyle(
                    color: _rankColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (rank <= 3)
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: _rankColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _rankColor.withOpacity(0.4),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Name
          Text(
            student.name.split(' ').first,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          // Level & Points
          Text(
            'Lvl $_level • $_points pts',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Elite Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _rankColor.withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Text(
              rank <= 3 ? '★ ELITE' : 'TOP 10',
              style: TextStyle(
                color: _rankColor,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 2: CGPA Distribution ─────────────────────────────────────────────
class _CgpaDistributionCard extends StatelessWidget {
  final List<Student> students;

  const _CgpaDistributionCard({required this.students});

  @override
  Widget build(BuildContext context) {
    // Build distribution buckets
    final buckets = <String, int>{
      '0–2': 0,
      '2–4': 0,
      '4–6': 0,
      '6–8': 0,
      '8–10': 0,
    };
    for (final s in students) {
      if (s.cgpa < 2) {
        buckets['0–2'] = buckets['0–2']! + 1;
      } else if (s.cgpa < 4) {
        buckets['2–4'] = buckets['2–4']! + 1;
      } else if (s.cgpa < 6) {
        buckets['4–6'] = buckets['4–6']! + 1;
      } else if (s.cgpa < 8) {
        buckets['6–8'] = buckets['6–8']! + 1;
      } else {
        buckets['8–10'] = buckets['8–10']! + 1;
      }
    }

    final maxCount = buckets.values.fold(1, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (students.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No CGPA data available',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.entries.map((e) {
                final ratio = maxCount > 0 ? e.value / maxCount : 0.0;
                final barH = (ratio * 90).clamp(10.0, 90.0);
                final isHighest = e.value == maxCount && e.value > 0;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${e.value}',
                        style: TextStyle(
                          color: isHighest
                              ? const Color(0xFF00E676)
                              : Colors.white54,
                          fontSize: 10,
                          fontWeight: isHighest
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: barH,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          gradient: isHighest
                              ? const LinearGradient(
                                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : null,
                          color: isHighest ? null : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isHighest
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withOpacity(0.15),
                                    blurRadius: 6,
                                  )
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${students.length} students enrolled • CGPA range distribution',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section 3: Search + Filters (Focus-glowing search, glass dropdowns) ───────
class _SearchFilterRow extends StatefulWidget {
  final TextEditingController controller;
  final String selectedBranch;
  final String selectedReadiness;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onReadinessChanged;
  final VoidCallback onApply;

  const _SearchFilterRow({
    required this.controller,
    required this.selectedBranch,
    required this.selectedReadiness,
    required this.onBranchChanged,
    required this.onReadinessChanged,
    required this.onApply,
  });

  @override
  State<_SearchFilterRow> createState() => _SearchFilterRowState();
}

class _SearchFilterRowState extends State<_SearchFilterRow> {
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  bool _isBtnPressed = false;

  static const _branches = [
    'All Branches', 'CSE', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL'
  ];
  static const _readiness = [
    'All Readiness', 'MNC Ready', 'Average', 'At Risk'
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search + Apply row
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFF091E19).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isSearchFocused
                        ? const Color(0xFF00E676)
                        : const Color(0xFF00C853).withOpacity(0.15),
                    width: _isSearchFocused ? 1.5 : 1.0,
                  ),
                  boxShadow: _isSearchFocused
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _searchFocus,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search by identity or branch...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                    prefixIcon: Icon(Icons.search, color: Colors.white30, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTapDown: (_) => setState(() => _isBtnPressed = true),
              onTapUp: (_) => setState(() => _isBtnPressed = false),
              onTapCancel: () => setState(() => _isBtnPressed = false),
              onTap: widget.onApply,
              child: AnimatedScale(
                scale: _isBtnPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Dropdowns row
        Row(
          children: [
            Expanded(
              child: _CompactDropdown(
                value: widget.selectedBranch,
                items: _branches,
                onChanged: widget.onBranchChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactDropdown(
                value: widget.selectedReadiness,
                items: _readiness,
                onChanged: widget.onReadinessChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CompactDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF091E19).withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00C853).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF031410),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          iconEnabledColor: const Color(0xFF00E676).withOpacity(0.7),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Section 4: Readiness Matrix Card (Glassmorphic cards with glowing border) ──
class _ReadinessCard extends StatelessWidget {
  final Student student;

  const _ReadinessCard({required this.student});

  Color get _statusColor {
    switch (student.status) {
      case 'MNC Ready':
        return const Color(0xFF00E676);
      case 'Average':
        return Colors.orange;
      case 'At Risk':
        return Colors.redAccent;
      default:
        return Colors.white38;
    }
  }

  int get _mockScore => (student.score * 0.9).round().clamp(0, 100);
  int get _level => (student.score / 20).ceil().clamp(1, 5);
  int get _points => student.score * 12;
  int get _streak => (student.score / 14).round().clamp(0, 30);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _statusColor.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _statusColor.withOpacity(0.01),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + Name/Email + Status badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _statusColor.withOpacity(0.08),
                child: Text(
                  student.initials,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.email,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  student.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 12),

          // Row 2: Metrics grid
          Row(
            children: [
              _MetricChip(
                label: 'Branch',
                value: student.branch,
                icon: Icons.school_outlined,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'CGPA',
                value: student.cgpa.toStringAsFixed(1),
                icon: Icons.grade_outlined,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Mock',
                value: '$_mockScore%',
                icon: Icons.quiz_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetricChip(
                label: 'Engagement',
                value: 'Lvl $_level • $_points pts',
                icon: Icons.bolt_outlined,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Streak',
                value: '$_streak 🔥',
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.02),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white30, size: 12),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white30, fontSize: 9.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer placeholders ───────────────────────────────────────────────────────
class _ShimmerBlock extends StatelessWidget {
  final double height;
  const _ShimmerBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.05)),
      ),
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) => Container(
          width: 124,
          decoration: BoxDecoration(
            color: const Color(0xFF061511).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }
}

class _VerticalShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 146,
          decoration: BoxDecoration(
            color: const Color(0xFF061511).withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.05),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white30, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
