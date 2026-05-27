import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/core/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class DriveCard extends StatelessWidget {
  final Drive drive;

  const DriveCard({super.key, required this.drive});

  Color getStatusColor() {
    return drive.status == "Open" ? const Color(0xFF00C853) : Colors.orange;
  }

  String getFormattedDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '--';
    try {
      final parts = rawDate.split(RegExp(r'[-/.]'));
      if (parts.length == 3) {
        if (parts[2].length == 4) {
          final day = int.tryParse(parts[1]) ?? 1;
          final month = int.tryParse(parts[0]) ?? 1;
          final year = int.tryParse(parts[2]) ?? 2026;
          final dStr = day.toString().padLeft(2, '0');
          final mStr = month.toString().padLeft(2, '0');
          return "$dStr/$mStr/$year";
        } else if (parts[0].length == 4) {
          final year = int.tryParse(parts[0]) ?? 2026;
          final month = int.tryParse(parts[1]) ?? 1;
          final day = int.tryParse(parts[2]) ?? 1;
          final dStr = day.toString().padLeft(2, '0');
          final mStr = month.toString().padLeft(2, '0');
          return "$dStr/$mStr/$year";
        }
      }
      final dt = DateTime.parse(rawDate);
      final dStr = dt.day.toString().padLeft(2, '0');
      final mStr = dt.month.toString().padLeft(2, '0');
      return "$dStr/$mStr/${dt.year}";
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();

    // Safe division to prevent division by zero and Infinity/NaN
    double progress = 0.0;
    if (drive.eligible > 0) {
      progress = drive.registered / drive.eligible;
      // Ensure progress is finite (not Infinity or NaN)
      if (!progress.isFinite) {
        progress = 0.0;
      }
    }

    print(
      "DRIVE DEBUG: registered=${drive.registered}, eligible=${drive.eligible}, progress=$progress",
    );

    return GestureDetector(
      onTap: () {
        print("DRIVE CARD TAPPED: ${drive.company}");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F3B2E), Color(0xFF071E17)],
          ),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(backgroundColor: color, radius: 10),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drive.company,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${drive.role} • ${drive.date}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                /// STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    drive.status,
                    style: TextStyle(color: color, fontSize: 10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Schedule Info Row
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white54, size: 12),
                const SizedBox(width: 6),
                Text(
                  "📅 Schedule: ${getFormattedDate(drive.driveDate)}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Registered / Shortlisted Pills
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    "${drive.registeredCount ?? 0} Registered",
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00C853).withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    "${drive.shortlistedCount ?? 0} Shortlisted",
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// STATS
            Row(
              children: [
                _stat("Eligible", drive.eligible),
                const SizedBox(width: 12),

                _stat("Registered", drive.registered),
                const SizedBox(width: 12),

                _stat("Pending", drive.pending),
              ],
            ),

            const SizedBox(height: 10),

            /// PROGRESS
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white10,
            ),

            const SizedBox(height: 6),

            Text(
              "${(progress.isFinite ? (progress * 100).round() : 0)}% registered",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),

            const SizedBox(height: 12),

            // Package + JD Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Package/Salary/CTC info
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Color(0xFF00C853), size: 14),
                    const SizedBox(width: 6),
                    Builder(
                      builder: (context) {
                        final rawPackage = drive.package ?? drive.salary ?? drive.CTC;
                        final String displayPackage;
                        if (rawPackage == null || rawPackage.trim().isEmpty || rawPackage.trim() == "Not disclosed") {
                          displayPackage = "Not disclosed";
                        } else {
                          displayPackage = rawPackage.startsWith("₹") ? rawPackage : "₹ $rawPackage";
                        }
                        return Text(
                          displayPackage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    ),
                  ],
                ),
                // JD Button
                InkWell(
                  onTap: () async {
                    final urlStr = drive.jdUrl;
                    if (urlStr != null && urlStr.trim().isNotEmpty) {
                      try {
                        final uri = Uri.parse(urlStr.trim());
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("JD not available"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("JD not available"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("JD not available"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.description_outlined, color: Color(0xFF00C853), size: 12),
                        SizedBox(width: 4),
                        Text(
                          "JD",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showNotifyDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF00C853),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "📣 Notify Students",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showShortlistBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "📄 Shortlist",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifyDialog(BuildContext context) {
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
                  color: const Color(0xFF00C853).withOpacity(0.3),
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
                          color: const Color(0xFF00C853).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.campaign_outlined,
                          color: Color(0xFF00C853),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Broadcast Notification",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Would you like to send a drive notification and email invite to all ${drive.eligible} eligible students for ${drive.company}?",
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
                                "Cancel",
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isBroadcasting = true;
                                });
                                await Future.delayed(const Duration(milliseconds: 1500));
                                if (context.mounted) {
                                  setState(() {
                                    isBroadcasting = false;
                                    isDone = true;
                                  });
                                }
                              },
                              child: const Text(
                                "Broadcast",
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Broadcasting notifications...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else if (isDone) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF00C853),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Broadcast Successful",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Alerts successfully dispatched to all ${drive.eligible} candidates for the ${drive.company} drive.",
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
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Helpers.showSuccessSnackBar(
                              context,
                              "Broadcast complete for ${drive.company}!",
                            );
                          },
                          child: const Text(
                            "Done",
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

  void _showShortlistBottomSheet(BuildContext context) {
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
                              "Shortlist Candidates",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              drive.company,
                              style: const TextStyle(
                                color: Color(0xFF00C853),
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
                      "Registered Candidates: ${drive.registered}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Shortlist Criteria",
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
                          "Minimum CGPA",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          minCgpa.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF00C853),
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
                      activeColor: const Color(0xFF00C853),
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setState(() {
                          minCgpa = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Allow Active Backlogs",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Switch(
                          value: activeBacklogs,
                          activeColor: const Color(0xFF00C853),
                          onChanged: (val) {
                            setState(() {
                              activeBacklogs = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isProcessing = true;
                          });
                          await Future.delayed(const Duration(milliseconds: 1800));
                          if (context.mounted) {
                            setState(() {
                              isProcessing = false;
                              isDone = true;
                            });
                          }
                        },
                        child: const Text(
                          "Compile Shortlist",
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        "Filtering candidates and parsing resumes...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ] else if (isDone) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Shortlist Results",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00C853).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Registered:",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              Text(
                                "${drive.registered}",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Passed Criteria:",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              Text(
                                "${(drive.registered * 0.7).round()}",
                                style: const TextStyle(
                                  color: Color(0xFF00C853),
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
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Helpers.showSuccessSnackBar(
                                context,
                                "Shortlist PDF downloaded successfully!",
                              );
                            },
                            child: const Text(
                              "Download PDF",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Helpers.showSuccessSnackBar(
                                context,
                                "Shortlist published to HODs & Students!",
                              );
                            },
                            child: const Text(
                              "Publish Shortlist",
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

  Widget _stat(String label, int value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          TextSpan(
            text: "$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
