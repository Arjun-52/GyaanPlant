import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../viewmodels/student_viewmodel/support_viewmodel.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  String searchQuery = '';
  String selectedStatusFilter = 'ALL STATUSES';
  String selectedPriorityFilter = 'ALL PRIORITIES';
  DateTime? selectedDateFilter;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportViewModel>().fetchTickets();
    });
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      context.read<SupportViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _applyAllFilters(BuildContext context, {String? status, String? priority, String? date, String? search}) {
    final supportVM = context.read<SupportViewModel>();
    
    // Status (lowercase or null)
    final activeStatus = status ?? (selectedStatusFilter == 'ALL STATUSES' ? null : selectedStatusFilter.toLowerCase());
    
    // Priority (lowercase or null)
    final activePriority = priority ?? (selectedPriorityFilter == 'ALL PRIORITIES' ? null : selectedPriorityFilter.split(' ').first.toLowerCase());
    
    // Date (yyyy-MM-dd or null)
    String? activeDate;
    final dateObj = date != null ? DateTime.tryParse(date) : selectedDateFilter;
    if (dateObj != null) {
      activeDate = "${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}";
    }

    // Search
    final activeSearch = search ?? searchQuery;

    supportVM.applyFilters(
      status: activeStatus,
      priority: activePriority,
      date: activeDate,
      search: activeSearch,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blueAccent;
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Resolved':
        return primaryGreen;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showCreateTicketBottomSheet(BuildContext context) {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'Technical Issue';
    String selectedPriority = 'Normal';
    String? attachedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF020F0C), // Dark green-black forest background
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: const Color(0xFF00E676).withOpacity(0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "CREATE NEW TICKET",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0C241E),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF00E676),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: const Color(0xFF00E676).withOpacity(0.15), height: 1),
                    const SizedBox(height: 24),

                    // Subject
                    const Text(
                      "SUBJECT",
                      style: TextStyle(
                        color: Color(0xFF759086),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Brief summary of the issue",
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFF020B08),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Type & Priority Row
                    Row(
                      children: [
                        // TYPE dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "TYPE",
                                style: TextStyle(
                                  color: Color(0xFF759086),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020B08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF00E676).withOpacity(0.2),
                                    width: 1.2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedType,
                                    dropdownColor: const Color(0xFF0D1F1A),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E676), size: 18),
                                    items: [
                                      'Technical Issue',
                                      'Billing & Payments',
                                      'General Inquiry'
                                    ].map((cat) {
                                      return DropdownMenuItem(value: cat, child: Text(cat));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedType = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // PRIORITY dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "PRIORITY",
                                style: TextStyle(
                                  color: Color(0xFF759086),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020B08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF00E676).withOpacity(0.2),
                                    width: 1.2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedPriority,
                                    dropdownColor: const Color(0xFF0D1F1A),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E676), size: 18),
                                    items: ['Low Priority', 'Normal', 'High', 'Urgent'].map((prio) {
                                      return DropdownMenuItem(value: prio, child: Text(prio));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedPriority = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      "DESCRIPTION",
                      style: TextStyle(
                        color: Color(0xFF759086),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Provide as much detail as possible...",
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFF020B08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Display Selected File name if any
                    if (attachedFileName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020B08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file_rounded, color: accentGreen, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                attachedFileName!,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  attachedFileName = null;
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.white60, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Attach File Button
                        GestureDetector(
                          onTap: () async {
                            try {
                              final result = await FilePicker.platform.pickFiles();
                              if (result != null && result.files.isNotEmpty) {
                                setModalState(() {
                                  attachedFileName = result.files.single.name;
                                });
                              }
                            } catch (e) {
                              print("Error picking file: $e");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C241E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00E676).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.image_outlined, color: Color(0xFF00E676), size: 16),
                                SizedBox(width: 8),
                                Text(
                                  "Attach File",
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Submit Ticket Button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (subjectController.text.trim().isEmpty ||
                                descriptionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all fields"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final fullDesc = attachedFileName != null
                                ? "${descriptionController.text.trim()}\n\n[Attached File: $attachedFileName]"
                                : descriptionController.text.trim();

                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            context.read<SupportViewModel>().createTicket(
                                  subject: subjectController.text.trim(),
                                  category: selectedType,
                                  priority: selectedPriority,
                                  description: fullDesc,
                                ).then((success) {
                              if (success) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text("Support Ticket raised successfully!"),
                                    backgroundColor: primaryGreen,
                                  ),
                                );
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to raise support ticket"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.send_rounded, size: 15),
                          label: const Text(
                            "Submit Ticket",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676), // Neon green button
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
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
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF07201B), Color(0xFF031612)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF00E676).withOpacity(0.08),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF07201B), Color(0xFF031612)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.08),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0C241E),
              shape: BoxShape.circle,
              border: Border.all(color: accentGreen.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.question_answer_rounded,
              color: accentGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Support Tickets Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Need help? Create your first support ticket.",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateTicketBottomSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Raise Ticket"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, SupportViewModel supportVM) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C0B0B), Color(0xFF160303)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF3C0C0C),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "An Error Occurred",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => supportVM.fetchTickets(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportVM = Provider.of<SupportViewModel>(context);
    final tickets = supportVM.tickets;

    // Stats calculations
    final int totalCount = supportVM.pagination?.total ?? tickets.length;
    final int openCount = tickets.where((t) => t.status.toLowerCase() == 'open').length;
    final int inProgressCount = tickets.where((t) => t.status.toLowerCase() == 'in progress' || t.status.toLowerCase() == 'pending').length;
    final int resolvedCount = tickets.where((t) => t.status.toLowerCase() == 'resolved').length;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background ambient glowing gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF02120F), Color(0xFF020907)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0A00E676),
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: accentGreen,
              backgroundColor: cardColor,
              onRefresh: () async {
                await supportVM.fetchTickets(isRefresh: true);
              },
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), // extra padding for FAB
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appbar Back Button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF07201B),
                          border: Border.all(
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. PREMIUM HEADER CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF07201B), Color(0xFF031612)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFF00E676).withOpacity(0.08),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Support Center",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Get help, track your tickets, and resolve issues.",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0C241E),
                              border: Border.all(
                                color: const Color(0xFF00E676).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.headset_mic_rounded,
                              color: Color(0xFF00E676),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. STATISTICS SECTION
                    Row(
                      children: [
                        _buildStatCard("Open", "$openCount", Colors.blueAccent),
                        const SizedBox(width: 10),
                        _buildStatCard("In Progress", "$inProgressCount", Colors.orangeAccent),
                        const SizedBox(width: 10),
                        _buildStatCard("Resolved", "$resolvedCount", primaryGreen),
                        const SizedBox(width: 10),
                        _buildStatCard("Total", "$totalCount", Colors.white),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. SEARCH & FILTERS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07201B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E676).withOpacity(0.08),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF020B08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF00E676).withOpacity(0.1),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: searchController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: "Search tickets...",
                                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                                      prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        searchQuery = val;
                                      });
                                    },
                                    onSubmitted: (val) {
                                      _applyAllFilters(context, search: val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _applyAllFilters(context, search: searchController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                child: const Text(
                                  "Search",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Date picker
                              Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDateFilter ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF00E676),
                                              onPrimary: Colors.black,
                                              surface: Color(0xFF0D1F1A),
                                              onSurface: Colors.white,
                                            ),
                                            dialogBackgroundColor: const Color(0xFF0D1F1A),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        selectedDateFilter = picked;
                                      });
                                      _applyAllFilters(context);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF020B08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            selectedDateFilter == null
                                                ? "mm/dd/yyyy"
                                                : "${selectedDateFilter!.month}/${selectedDateFilter!.day}/${selectedDateFilter!.year}",
                                            style: TextStyle(
                                              color: selectedDateFilter == null ? Colors.white38 : Colors.white70,
                                              fontSize: 11.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (selectedDateFilter != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedDateFilter = null;
                                              });
                                              _applyAllFilters(context);
                                            },
                                            child: const Icon(Icons.close, color: Colors.white60, size: 14),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Status Dropdown
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF020B08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatusFilter,
                                      dropdownColor: const Color(0xFF031612),
                                      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                                      items: const [
                                        DropdownMenuItem(value: "ALL STATUSES", child: Text("ALL")),
                                        DropdownMenuItem(value: "OPEN", child: Text("OPEN")),
                                        DropdownMenuItem(value: "IN PROGRESS", child: Text("IN PROGRESS")),
                                        DropdownMenuItem(value: "RESOLVED", child: Text("RESOLVED")),
                                        DropdownMenuItem(value: "CLOSED", child: Text("CLOSED")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedStatusFilter = val;
                                          });
                                          _applyAllFilters(context);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Priority Dropdown
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF020B08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedPriorityFilter,
                                      dropdownColor: const Color(0xFF031612),
                                      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                                      items: const [
                                        DropdownMenuItem(value: "ALL PRIORITIES", child: Text("ALL")),
                                        DropdownMenuItem(value: "URGENT", child: Text("URGENT")),
                                        DropdownMenuItem(value: "HIGH", child: Text("HIGH")),
                                        DropdownMenuItem(value: "NORMAL", child: Text("NORMAL")),
                                        DropdownMenuItem(value: "LOW", child: Text("LOW")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedPriorityFilter = val;
                                          });
                                          _applyAllFilters(context);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. TICKETS SECTION OR EMPTY STATE
                    const Text(
                      "My Support Tickets",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    supportVM.isLoading && tickets.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: accentGreen))
                        : supportVM.errorMessage != null && tickets.isEmpty
                            ? _buildErrorState(context, supportVM.errorMessage!, supportVM)
                            : tickets.isEmpty
                                ? _buildEmptyState(context)
                                : Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: tickets.length,
                                        itemBuilder: (context, index) {
                                          final ticket = tickets[index];
                                          final statusColor = _getStatusColor(ticket.status);
                                          final formattedDate =
                                              "${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}";

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(22),
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF0B2B23), Color(0xFF02100C)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFF00E676).withOpacity(0.12),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(22),
                                                onTap: () {
                                                  context.push('/support/ticket/${ticket.ticketId}');
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(18),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Header Row: Ticket ID + Status Badge
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            ticket.ticketId,
                                                            style: const TextStyle(
                                                              color: Color(0xFF00E676),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                          // Status tag
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                            decoration: BoxDecoration(
                                                              color: statusColor.withOpacity(0.12),
                                                              borderRadius: BorderRadius.circular(10),
                                                              border: Border.all(
                                                                color: statusColor.withOpacity(0.35),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              ticket.status,
                                                              style: TextStyle(
                                                                color: statusColor,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),

                                                      // Subject
                                                      Text(
                                                        ticket.subject,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          height: 1.3,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),

                                                      // Footer Row: Categories, Priority, Date
                                                      Row(
                                                        children: [
                                                          _buildInfoPill(ticket.category.toUpperCase(), Colors.white70),
                                                          const SizedBox(width: 8),
                                                          _buildInfoPill(
                                                            ticket.priority.toUpperCase(),
                                                            ticket.priority.toLowerCase().contains('critical') ||
                                                                    ticket.priority.toLowerCase().contains('urgent') ||
                                                                    ticket.priority.toLowerCase().contains('high')
                                                                ? Colors.redAccent
                                                                : Colors.orangeAccent,
                                                          ),
                                                          if (ticket.author?.name != null) ...[
                                                            const SizedBox(width: 8),
                                                            _buildInfoPill(ticket.author!.name!, Colors.white60),
                                                          ],
                                                          const Spacer(),
                                                          Text(
                                                            formattedDate,
                                                            style: const TextStyle(
                                                              color: Colors.white38,
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (supportVM.isLoadingMore)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(
                                            child: CircularProgressIndicator(color: accentGreen),
                                          ),
                                        ),
                                    ],
                                  ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketBottomSheet(context),
        backgroundColor: const Color(0xFF00E676),
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.black, size: 20),
        label: const Text(
          "Raise Ticket",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
