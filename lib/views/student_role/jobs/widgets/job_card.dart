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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2B22), Color(0xFF02110D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.02),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (Logo, Title, Company Name)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful Company Logo Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                  ),
                  color: const Color(0xFF020B08),
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
                          widget.logoColor.withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.logoColor.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
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
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.company}  •  ${widget.location}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.badgeColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.badgeText.toUpperCase(),
                    style: TextStyle(
                      color: widget.badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          /// AI MATCH %
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1F00E676),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF00E676),
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  "${widget.match} profile match".toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          /// TAGS / SKILLS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF031410),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.08),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 16),

          /// BOTTOM ROW (Salary & Apply CTA Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salary,
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Color(0x6600E676),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "EST. SALARY (LPA)",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  if (isApplied || isApplying) return;

                  try {
                    final shouldUpload = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF02100C),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00E676).withOpacity(0.15),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1F00E676),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00E676).withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_rounded,
                                    color: Color(0xFF00E676),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Upload Resume",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "To complete your application for this position, please upload your professional resume (PDF, DOC, or DOCX).",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00E676),
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Upload",
                                          style: TextStyle(fontWeight: FontWeight.w900),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF00E676)),
                          color: const Color(0x1A00E676),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              "Applied",
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00C853)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isApplying
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                "1-Click Apply",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
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
