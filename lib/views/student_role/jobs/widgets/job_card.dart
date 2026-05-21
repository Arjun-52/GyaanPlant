import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gyaanplant/core/utils/helpers.dart';

class JobCard extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String match;
  final List<String> tags;
  final Color logoColor;
  final bool showBadge;
  final String badgeText;
  final Color badgeColor;

  const JobCard({
    required this.logoColor,
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.match,
    required this.tags,
    this.showBadge = false,
    this.badgeText = "",
    this.badgeColor = Colors.green,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool isApplied = false;
  bool isApplying = false;
  String? uploadedResumeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F19),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  TOP ROW
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF132F27),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.logoColor,
                          widget.logoColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${widget.company} — ${widget.location}",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              ///  Badge
              if (widget.showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.badgeColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.badgeText,
                    style: TextStyle(
                      color: widget.badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          /// MATCH %
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "${widget.match} profile match",
                style: const TextStyle(color: Color(0xFF00C853), fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ///  TAGS
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF102821),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          ///  BOTTOM ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Salary
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salary,
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "LPA",
                    style: TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ],
              ),

              /// BUTTON
              GestureDetector(
                onTap: () async {
                  if (isApplied || isApplying) return;

                  try {
                    // Show a custom popup card prompting the user to upload a resume
                    final shouldUpload = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1F19),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF12352C),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon / Header representation
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF102821),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00C853).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Color(0xFF00C853),
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Title
                                const Text(
                                  "Upload Resume",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Description
                                const Text(
                                  "To complete your application for this position, please upload your professional resume (PDF, DOC, or DOCX).",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white60,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00C853),
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Upload",
                                          style: TextStyle(fontWeight: FontWeight.bold),
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

                    if (shouldUpload != true) return;

                    // Navigate to dynamic drive/file-explorer
                    final FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                      allowMultiple: false,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final fileName = file.name;

                      setState(() {
                        isApplying = true;
                      });

                      // Premium UI experience: Simulate resume uploading state
                      await Future.delayed(const Duration(milliseconds: 1500));

                      if (context.mounted) {
                        setState(() {
                          isApplying = false;
                          isApplied = true;
                          uploadedResumeName = fileName;
                        });

                        Helpers.showSuccessSnackBar(
                          context,
                          "Applied successfully with resume: $fileName!",
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Helpers.showInfoSnackBar(
                          context,
                          "Application cancelled. Resume upload is required to apply.",
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Helpers.showErrorSnackBar(
                        context,
                        "Failed to upload resume. Please try again.",
                      );
                    }
                  }
                },
                child: isApplied
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00C853)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "✓ Applied",
                              style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (uploadedResumeName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                uploadedResumeName!,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isApplying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                "1-Click Apply",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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
}
