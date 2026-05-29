import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class RoleCard extends StatefulWidget {
  final RoleModel role;

  const RoleCard({super.key, required this.role});

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> with SingleTickerProviderStateMixin {
  bool _isSelected = false;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _arrowAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  String _getPremiumTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('student')) return "Student";
    if (lower.contains('tpo')) return "TPO – Training & Placement Officer";
    if (lower.contains('hod') || lower.contains('principal')) return "HOD / Principal";
    if (lower.contains('mentor') || lower.contains('alumni')) return "Alumni Mentor";
    return title;
  }

  String _getPremiumDescription(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('student')) return "Learn, practice, earn certificates, and get placed.";
    if (lower.contains('tpo')) return "Track placements, monitor readiness, manage drives.";
    if (lower.contains('hod') || lower.contains('principal')) return "Department insights, analytics, accreditation monitoring.";
    if (lower.contains('mentor') || lower.contains('alumni')) return "Mentor students, manage sessions, track impact.";
    return widget.role.subtitle;
  }

  String _getPremiumIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('student')) return "🎓";
    if (lower.contains('tpo')) return "🏫";
    if (lower.contains('hod') || lower.contains('principal')) return "📐";
    if (lower.contains('mentor') || lower.contains('alumni')) return "👨‍🏫";
    return widget.role.icon;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _getPremiumTitle(widget.role.title);
    final descText = _getPremiumDescription(widget.role.title);
    final iconText = _getPremiumIcon(widget.role.title);

    return AnimatedScale(
      scale: _isSelected ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFA3).withValues(
                alpha: _isSelected ? 0.12 : 0.03,
              ),
              blurRadius: _isSelected ? 25 : 15,
              spreadRadius: _isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () async {
                setState(() {
                  _isSelected = true;
                });
                // Beautiful short delay to let ripple and scale animation render
                await Future.delayed(const Duration(milliseconds: 250));
                if (!mounted) return;

                final title = widget.role.title.toLowerCase();
                String selectedRole = 'student';

                if (title.contains('student')) {
                  selectedRole = 'student';
                } else if (title.contains('tpo')) {
                  selectedRole = 'tpo';
                } else if (title.contains('hod') || title.contains('principal')) {
                  selectedRole = 'hod';
                } else if (title.contains('mentor') || title.contains('alumni')) {
                  selectedRole = 'mentor';
                }

                await LocalStorageService.saveRole(selectedRole);
                AuthCache.role = selectedRole;
                if (context.mounted) {
                  context.go('/signin');
                }
              },
              splashColor: const Color(0xFF00FFA3).withValues(alpha: 0.15),
              highlightColor: const Color(0xFF00FFA3).withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _isSelected
                        ? const Color(0xFF00FFA3).withValues(alpha: 0.7)
                        : const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    width: _isSelected ? 1.8 : 1.2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isSelected
                        ? [
                            const Color(0xFF0F3B2E).withValues(alpha: 0.45),
                            const Color(0xFF041913).withValues(alpha: 0.9),
                          ]
                        : [
                            const Color(0xFF0A1410).withValues(alpha: 0.55),
                            const Color(0xFF030806).withValues(alpha: 0.85),
                          ],
                  ),
                ),
                child: Row(
                  children: [
                    // Large Circular Glowing Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _isSelected
                            ? const Color(0xFF00FFA3).withValues(alpha: 0.2)
                            : const Color(0xFF0C241B).withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSelected
                              ? const Color(0xFF00FFA3).withValues(alpha: 0.8)
                              : const Color(0xFF00FFA3).withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withValues(
                              alpha: _isSelected ? 0.35 : 0.1,
                            ),
                            blurRadius: _isSelected ? 15 : 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        iconText,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),

                    const SizedBox(width: 18),

                    // Card Text Content (Role Name & Description)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _isSelected ? const Color(0xFF00FFA3) : Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            descText,
                            style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 13.5,
                              color: Colors.white.withValues(alpha: 0.65),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Animated Arrow Icon
                    AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_arrowAnimation.value, 0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: _isSelected
                                ? const Color(0xFF00FFA3)
                                : const Color(0xFF00FFA3).withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
