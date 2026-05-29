import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/student_details_screen.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/edit_student_screen.dart';
import 'package:provider/provider.dart';

class StudentCard extends StatefulWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'MNC Ready':
        return const Color(0xFF00C853);
      case 'Average':
        return Colors.orange;
      case 'At Risk':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(widget.student.status);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverCtrl.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverCtrl.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(18),
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
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Avatar, Name, Email, Status Badge, Score
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF0C2D24),
                      radius: 22,
                      child: Text(
                        widget.student.initials,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.name,
                          style: const TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.student.email,
                          style: TextStyle(
                            fontFamily: 'Gilroy-Medium',
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.student.score}",
                        style: TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: statusColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "score",
                        style: TextStyle(color: Colors.white38, fontSize: 9.5),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      widget.student.status,
                      style: TextStyle(
                        fontFamily: 'Gilroy-Bold',
                        color: statusColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Student Metrics Section (Roll No, Program, Year, CGPA inside mini cards)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBlock(
                      label: 'Roll Number',
                      value: widget.student.rollNo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBlock(
                      label: 'Program & Year',
                      value: "${widget.student.branch} • ${widget.student.year}",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBlock(
                      label: 'CGPA',
                      value: widget.student.cgpa.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Career Path Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, color: Color(0xFF00FFA3), size: 14),
                    const SizedBox(width: 10),
                    const Text(
                      "Career Profile: ",
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Expanded(
                      child: Text(
                        widget.student.careerPath,
                        style: const TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Section (View, Edit, Nudge)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: '👁 View',
                    onTap: () {
                      final studentVm = context.read<StudentViewModel>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: studentVm,
                            child: StudentDetailsScreen(student: widget.student),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    label: '✏ Edit',
                    onTap: () {
                      final studentVm = context.read<StudentViewModel>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: studentVm,
                            child: EditStudentScreen(student: widget.student),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    label: '🔔 Nudge',
                    color: statusColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nudged ${widget.student.name} successfully!'),
                          backgroundColor: const Color(0xFF0C2D24),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBlock({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final displayColor = color ?? Colors.white70;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: displayColor,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
