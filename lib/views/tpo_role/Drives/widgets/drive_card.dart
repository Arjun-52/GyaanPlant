import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/core/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DriveCard – premium glassmorphism recruitment drive card
// All original logic (notify, shortlist, JD launch) is preserved exactly.
// ─────────────────────────────────────────────────────────────────────────────
class DriveCard extends StatefulWidget {
  final Drive drive;
  const DriveCard({super.key, required this.drive});

  @override
  State<DriveCard> createState() => _DriveCardState();
}

class _DriveCardState extends State<DriveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.06, end: 0.14).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return const Color(0xFF00FFAA);
      case 'upcoming':
        return const Color(0xFF60A5FA);
      case 'closed':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.white38;
      default:
        return const Color(0xFF00C853);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return 'Active';
      case 'upcoming':
        return 'Upcoming';
      case 'closed':
        return 'Closed';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '--';
    try {
      final parts = raw.split(RegExp(r'[-/.]'));
      if (parts.length == 3) {
        if (parts[2].length == 4) {
          return '${parts[1].padLeft(2, '0')}/${parts[0].padLeft(2, '0')}/${parts[2]}';
        } else if (parts[0].length == 4) {
          return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
        }
      }
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _companyInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final drive = widget.drive;
    final statusColor = _statusColor(drive.status);

    double progress = 0.0;
    if (drive.eligible > 0) {
      progress = (drive.registered / drive.eligible).clamp(0.0, 1.0);
      if (!progress.isFinite) progress = 0.0;
    }

    print(
      'DRIVE DEBUG: registered=${drive.registered}, eligible=${drive.eligible}, progress=$progress',
    );

    final rawPackage = drive.package ?? drive.salary ?? drive.CTC;
    final displayPackage =
        (rawPackage == null || rawPackage.trim().isEmpty || rawPackage.trim() == 'Not disclosed')
            ? 'Not disclosed'
            : rawPackage.startsWith('₹')
                ? rawPackage
                : '₹ $rawPackage';

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            print('DRIVE CARD TAPPED: ${drive.company}');
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.984 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0E2A1A), Color(0xFF061510)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: statusColor.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(_glowAnim.value),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(drive, statusColor),
            const SizedBox(height: 16),
            _buildStatsRow(drive),
            const SizedBox(height: 16),
            _buildProgressSection(drive, progress, statusColor),
            const SizedBox(height: 16),
            _buildInfoRow(drive, displayPackage),
            const SizedBox(height: 16),
            _buildActionButtons(context, drive),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildCardHeader(Drive drive, Color statusColor) {
    return Row(
      children: [
        // Company avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.25),
                statusColor.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(
              _companyInitials(drive.company),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                drive.company,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                drive.role,
                style: const TextStyle(
                  color: Color(0xFF6B8F76),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 10,
                    color: Color(0xFF6B8F76),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(drive.driveDate ?? drive.date),
                    style: const TextStyle(
                      color: Color(0xFF6B8F76),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Status badge
        _StatusBadge(label: _statusLabel(drive.status), color: statusColor),
      ],
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStatsRow(Drive drive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF00FFAA).withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00FFAA).withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statChip('👨‍🎓', '${drive.eligible}', 'Eligible'),
          _divider(),
          _statChip('📝', '${drive.registered}', 'Registered'),
          _divider(),
          _statChip('⏳', '${drive.pending}', 'Pending'),
          _divider(),
          _statChip('🎯', '${drive.shortlistedCount ?? 0}', 'Shortlisted'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: Colors.white.withOpacity(0.07),
      );

  Widget _statChip(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B8F76),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ── Progress ───────────────────────────────────────────────────────────────
  Widget _buildProgressSection(Drive drive, double progress, Color statusColor) {
    final percent = (progress.isFinite ? (progress * 100).round() : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Registration Progress',
              style: TextStyle(color: Color(0xFF8A9E94), fontSize: 12),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                '$percent%',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Info row ───────────────────────────────────────────────────────────────
  Widget _buildInfoRow(Drive drive, String displayPackage) {
    return Row(
      children: [
        // Package
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Color(0xFF00FFAA),
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  displayPackage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // JD Button
        GestureDetector(
          onTap: () => _launchJD(context, drive),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFAA).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00FFAA).withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Color(0xFF00FFAA),
                  size: 12,
                ),
                SizedBox(width: 5),
                Text(
                  'View JD',
                  style: TextStyle(
                    color: Color(0xFF00FFAA),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, Drive drive) {
    return Row(
      children: [
        Expanded(
          child: _PremiumButton(
            label: '📢  Notify Students',
            isPrimary: true,
            onTap: () => _showNotifyDialog(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PremiumButton(
            label: '📄  Manage Shortlist',
            isPrimary: false,
            onTap: () => _showShortlistBottomSheet(context),
          ),
        ),
      ],
    );
  }

  // ── JD Launch ──────────────────────────────────────────────────────────────
  void _launchJD(BuildContext context, Drive drive) async {
    final urlStr = drive.jdUrl;
    if (urlStr != null && urlStr.trim().isNotEmpty) {
      try {
        final uri = Uri.parse(urlStr.trim());
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showJDError(context);
        }
      } catch (_) {
        _showJDError(context);
      }
    } else {
      _showJDError(context);
    }
  }

  void _showJDError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('JD not available'),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Notify Dialog (preserved logic) ────────────────────────────────────────
  void _showNotifyDialog(BuildContext context) {
    final drive = widget.drive;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        bool isBroadcasting = false;
        bool isDone = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF071E17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF00FFAA).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isBroadcasting && !isDone) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFAA).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.campaign_outlined,
                          color: Color(0xFF00FFAA),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Broadcast Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Would you like to send a drive notification and email invite to all ${drive.eligible} eligible students for ${drive.company}?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFAA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                setState(() => isBroadcasting = true);
                                await Future.delayed(
                                    const Duration(milliseconds: 1500));
                                if (context.mounted) {
                                  setState(() {
                                    isBroadcasting = false;
                                    isDone = true;
                                  });
                                }
                              },
                              child: const Text(
                                'Broadcast',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isBroadcasting) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00FFAA)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Broadcasting notifications...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                    ] else if (isDone) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFAA).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF00FFAA),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Broadcast Successful',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Alerts successfully dispatched to all ${drive.eligible} candidates for the ${drive.company} drive.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FFAA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Helpers.showSuccessSnackBar(
                              context,
                              'Broadcast complete for ${drive.company}!',
                            );
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Shortlist Bottom Sheet (preserved logic) ────────────────────────────────
  void _showShortlistBottomSheet(BuildContext context) {
    final drive = widget.drive;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF071E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isProcessing = false;
        bool isDone = false;
        double minCgpa = 7.5;
        bool activeBacklogs = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isProcessing && !isDone) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shortlist Candidates',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              drive.company,
                              style: const TextStyle(
                                color: Color(0xFF00FFAA),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Registered Candidates: ${drive.registered}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Shortlist Criteria',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Minimum CGPA',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          minCgpa.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF00FFAA),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: minCgpa,
                      min: 5.0,
                      max: 9.5,
                      divisions: 9,
                      activeColor: const Color(0xFF00FFAA),
                      inactiveColor: Colors.white10,
                      onChanged: (val) => setState(() => minCgpa = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Allow Active Backlogs',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        Switch(
                          value: activeBacklogs,
                          activeColor: const Color(0xFF00FFAA),
                          onChanged: (val) =>
                              setState(() => activeBacklogs = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFAA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          setState(() => isProcessing = true);
                          await Future.delayed(
                              const Duration(milliseconds: 1800));
                          if (context.mounted) {
                            setState(() {
                              isProcessing = false;
                              isDone = true;
                            });
                          }
                        },
                        child: const Text(
                          'Compile Shortlist',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ] else if (isProcessing) ...[
                    const SizedBox(height: 40),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00FFAA)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Filtering candidates and parsing resumes...',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ] else if (isDone) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shortlist Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFAA).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFF00FFAA).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Registered:',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14),
                              ),
                              Text(
                                '${drive.registered}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Passed Criteria:',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14),
                              ),
                              Text(
                                '${(drive.registered * 0.7).round()}',
                                style: const TextStyle(
                                  color: Color(0xFF00FFAA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Helpers.showSuccessSnackBar(
                                context,
                                'Shortlist PDF downloaded successfully!',
                              );
                            },
                            child: const Text(
                              'Download PDF',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFAA),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Helpers.showSuccessSnackBar(
                                context,
                                'Shortlist published to HODs & Students!',
                              );
                            },
                            child: const Text(
                              'Publish Shortlist',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Button
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  const _PremiumButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: _pressed
                        ? [const Color(0xFF00D090), const Color(0xFF00A844)]
                        : [const Color(0xFF00FFAA), const Color(0xFF00C853)],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: const Color(0xFF00FFAA).withOpacity(0.3),
                  ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF00FFAA)
                          .withOpacity(_pressed ? 0.15 : 0.25),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isPrimary
                  ? Colors.black
                  : const Color(0xFF00FFAA),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
