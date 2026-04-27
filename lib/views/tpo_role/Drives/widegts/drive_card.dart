import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';

class DriveCard extends StatelessWidget {
  final Drive drive;

  const DriveCard({super.key, required this.drive});

  Color getStatusColor() {
    return drive.status == "Open" ? const Color(0xFF00C853) : Colors.orange;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF071E17)],
        ),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
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

          /// BUTTONS
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 10),
              Expanded(
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
            ],
          ),
        ],
      ),
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
