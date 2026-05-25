import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';

class UpcomingDriveCard extends StatelessWidget {
  final UpcomingDrive drive;

  const UpcomingDriveCard({super.key, required this.drive});

  String _formatDriveDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.tryParse(dateStr);
      if (date == null) return dateStr;

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = drive.status?.toLowerCase() == 'open';
    final Color statusColor = isOpen ? const Color(0xFF00C853) : Colors.amber;
    final double cardWidth = MediaQuery.of(context).size.width - 32;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row: Logo, Company Name & Role, Status Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drive.company ?? 'Unknown Company',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drive.role ?? 'Software Engineer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (drive.status != null && drive.status!.isNotEmpty)
                _buildStatusChip(drive.status!, statusColor),
            ],
          ),

          // Badges / Middle Info (Job Type, Salary Package, JD)
          Row(
            children: [
              if (drive.jobType != null && drive.jobType!.isNotEmpty) ...[
                _buildBadge(
                  text: drive.jobType!,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  textColor: Colors.white70,
                ),
                const SizedBox(width: 8),
              ],
              if (drive.package != null && drive.package!.isNotEmpty) ...[
                _buildBadge(
                  text: drive.package!,
                  backgroundColor: const Color(0xFF00C853).withOpacity(0.1),
                  textColor: const Color(0xFF00C853),
                  borderColor: const Color(0xFF00C853).withOpacity(0.3),
                ),
                const SizedBox(width: 8),
              ],
              if (drive.jdAvailable == true)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF00C853),
                    size: 14,
                  ),
                ),
            ],
          ),

          // Chips / Metrics Row (Registered, Shortlisted, Eligible)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (drive.registeredCount != null)
                _buildMetricChip(
                  label: '${drive.registeredCount} Registered',
                  color: Colors.blueAccent,
                ),
              if (drive.shortlistedCount != null)
                _buildMetricChip(
                  label: '${drive.shortlistedCount} Shortlisted',
                  color: Colors.purpleAccent,
                ),
              if (drive.eligibleCount != null)
                _buildMetricChip(
                  label: '${drive.eligibleCount} Eligible',
                  color: const Color(0xFF00C853),
                ),
            ],
          ),

          // Bottom Section: Schedule Date
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white54,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  drive.driveDate != null && drive.driveDate!.isNotEmpty
                      ? 'Schedule: ${_formatDriveDate(drive.driveDate)}'
                      : 'Schedule: Not set',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    final companyName = drive.company ?? '?';
    final initialLetter = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0C2D24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C853).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: drive.companyLogo != null && drive.companyLogo!.isNotEmpty
            ? Image.network(
                drive.companyLogo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initialLetter,
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  initialLetter,
                  style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
