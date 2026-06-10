import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/departments_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/depts/screens/add_college_department_screen.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/department_card.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> with TickerProviderStateMixin {
  late final DepartmentsViewModel _vm;
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  // Screen load animations (nullable to prevent LateInitializationErrors during hot reload)
  AnimationController? _headerAnimController;
  Animation<double>? _headerFade;
  Animation<Offset>? _headerSlide;

  AnimationController? _searchAnimController;
  Animation<double>? _searchFade;
  Animation<Offset>? _searchSlide;

  @override
  void initState() {
    super.initState();
    _vm = DepartmentsViewModel();
    _searchController = TextEditingController();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Initialize animations
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController!, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0.0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerAnimController!, curve: Curves.easeOutBack),
    );

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _searchFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimController!,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _searchSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _searchAnimController!,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vm.loadDepartments();
        _headerAnimController?.forward();
        _searchAnimController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _headerAnimController?.dispose();
    _searchAnimController?.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08), // Deep black background
        body: Stack(
          children: [
            // ── Background Glow Accent ──────────────────────────────────
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.06),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.06),
                        blurRadius: 100,
                        spreadRadius: 40,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
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
                      spreadRadius: 50,
                    )
                  ],
                ),
              ),
            ),

            // ── Main Content ─────────────────────────────────────────────
            Consumer<DepartmentsViewModel>(
              builder: (context, vm, _) {
                // Loading State
                if (vm.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00E676),
                    ),
                  );
                }

                // Error State
                if (vm.error != null) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1813),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            vm.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => vm.loadDepartments(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // No Departments Found (Entire Screen Empty)
                if (vm.departments.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildHeader(context),
                          const Spacer(),
                          _buildEmptyState(),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                }

                final displayed = vm.filteredDepartments;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header Row ──────────────────────────────────────────
                        SlideTransition(
                          position: _headerSlide ?? const AlwaysStoppedAnimation(Offset.zero),
                          child: FadeTransition(
                            opacity: _headerFade ?? const AlwaysStoppedAnimation(1.0),
                            child: _buildHeader(context),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Search & Filter Panel ────────────────────────────────
                        SlideTransition(
                          position: _searchSlide ?? const AlwaysStoppedAnimation(Offset.zero),
                          child: FadeTransition(
                            opacity: _searchFade ?? const AlwaysStoppedAnimation(1.0),
                            child: _buildSearchSection(vm),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── List / Empty Search Results State ────────────────────
                        Expanded(
                          child: displayed.isEmpty && vm.searchQuery.isNotEmpty
                              ? Center(
                                  child: _buildEmptyState(
                                    title: "No Results Found",
                                    subtitle: "Try adjusting your search or filters.",
                                  ),
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
                                  itemCount: displayed.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                                  itemBuilder: (_, i) {
                                    return AnimatedStaggerItem(
                                      index: i,
                                      child: DepartmentCard(dept: displayed[i]),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Departments',
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
                  'Manage Institutional Units',
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
        const Spacer(),
        // ── Add College Dept button ─────────────────────────
        _AddDeptButton(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: _vm,
                child: const AddCollegeDepartmentScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(DepartmentsViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.04),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF0B1914).withOpacity(0.85),
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFF00E676).withOpacity(0.5)
                      : const Color(0xFF00C853).withOpacity(0.12),
                  width: _isSearchFocused ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: vm.updateQuery,
                decoration: InputDecoration(
                  hintText: 'Filter units by name or code...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isSearchFocused ? const Color(0xFF00E676) : Colors.white38,
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── APPLY button ────────────────────────────────────
          _ApplyFilterButton(
            onTap: () {
              FocusScope.of(context).unfocus();
              vm.applyFilter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    String title = "🏫 No Departments Available",
    String subtitle = "Departments will appear here once added.",
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1C16), Color(0xFF03100C)],
          ),
          border: Border.all(
            color: const Color(0xFF00E676).withOpacity(0.1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing illustration/emoji container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF00E676).withOpacity(0.12), const Color(0xFF00C853).withOpacity(0.04)],
                ),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '🏫',
                style: TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Staggered list element entrance ────────────────────────────────────
class AnimatedStaggerItem extends StatefulWidget {
  final int index;
  final Widget child;
  const AnimatedStaggerItem({super.key, required this.index, required this.child});

  @override
  State<AnimatedStaggerItem> createState() => _AnimatedStaggerItemState();
}

class _AnimatedStaggerItemState extends State<AnimatedStaggerItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _visible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: _visible ? Offset.zero : const Offset(0.0, 0.2),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ── "Add College Dept" CTA button ─────────────────────────────────────
class _AddDeptButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddDeptButton({required this.onTap});

  @override
  State<_AddDeptButton> createState() => _AddDeptButtonState();
}

class _AddDeptButtonState extends State<_AddDeptButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00C853)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: Colors.black),
              SizedBox(width: 4),
              Text(
                'Add College Dept',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── "APPLY" CTA button ────────────────────────────────────────────────
class _ApplyFilterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ApplyFilterButton({required this.onTap});

  @override
  State<_ApplyFilterButton> createState() => _ApplyFilterButtonState();
}

class _ApplyFilterButtonState extends State<_ApplyFilterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF0B1914),
            border: Border.all(
              color: const Color(0xFF00E676).withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.1),
                blurRadius: 8,
              )
            ],
          ),
          child: const Text(
            'APPLY',
            style: TextStyle(
              color: Color(0xFF00E676),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
