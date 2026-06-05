import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/student_viewmodel/support_viewmodel.dart';
import '../../../../core/utils/helpers.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  final replyController = TextEditingController();
  final scrollController = ScrollController();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blueAccent;
      case 'in progress':
      case 'pending':
        return Colors.orangeAccent;
      case 'resolved':
        return primaryGreen;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportViewModel>().fetchTicketDetails(widget.ticketId).then((_) {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    replyController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportVM = Provider.of<SupportViewModel>(context);

    // 1. Loading State
    if (supportVM.isLoadingDetails && supportVM.selectedTicketDetails == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: accentGreen),
        ),
      );
    }

    // 2. Error State
    if (supportVM.detailsErrorMessage != null && supportVM.selectedTicketDetails == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  supportVM.detailsErrorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => supportVM.fetchTicketDetails(widget.ticketId),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Not Found
    final ticket = supportVM.selectedTicketDetails;
    
    debugPrint("🎫 [TicketDetailsScreen UI] build() - selectedTicketDetails: $ticket");
    if (ticket != null) {
      debugPrint("🎫 [TicketDetailsScreen UI] widget.ticketId='${widget.ticketId}'");
      debugPrint("🎫 [TicketDetailsScreen UI] ticket.ticketId='${ticket.ticketId}'");
      debugPrint("🎫 [TicketDetailsScreen UI] ticket.id='${ticket.id}'");
      debugPrint("🎫 [TicketDetailsScreen UI] ticket.dbId='${ticket.dbId}'");
    }

    final bool isCorrectTicket = ticket != null &&
        (ticket.ticketId == widget.ticketId ||
         ticket.id == widget.ticketId ||
         ticket.dbId == widget.ticketId);

    debugPrint("🎫 [TicketDetailsScreen UI] isCorrectTicket=$isCorrectTicket");

    if (ticket == null || !isCorrectTicket) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Ticket details not found", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(ticket.status);
    final formattedDate =
        "${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Ticket ${ticket.ticketId}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ticket Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentGreen.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Priority: ${ticket.priority.toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Status tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          ticket.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (ticket.attachment != null && ticket.attachment!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, color: accentGreen, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Attachment: ${ticket.attachment}",
                            style: const TextStyle(color: accentGreen, fontSize: 12, decoration: TextDecoration.underline),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.white38, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            ticket.author?.name ?? "Student",
                            style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "Created: $formattedDate",
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Conversation",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Message / Chat history with RefreshIndicator for Pull to Refresh
            Expanded(
              child: RefreshIndicator(
                color: accentGreen,
                backgroundColor: cardColor,
                onRefresh: () async {
                  await supportVM.fetchTicketDetails(widget.ticketId, isRefresh: true);
                },
                child: ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, index) {
                    final message = ticket.messages[index];
                    final isStudent = message.sender == 'student';
                    final timeText =
                        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

                    return Align(
                      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isStudent ? const Color(0xFF0F3B2E) : cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isStudent ? 16 : 0),
                            bottomRight: Radius.circular(isStudent ? 0 : 16),
                          ),
                          border: Border.all(
                            color: isStudent
                                ? accentGreen.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sender Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isStudent ? "You" : (message.author?.name ?? "Support Team"),
                                  style: TextStyle(
                                    color: isStudent ? accentGreen : Colors.orangeAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isStudent && message.author?.role != null)
                                  Text(
                                    message.author!.role!.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                            if (message.attachment != null && message.attachment!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.attach_file_rounded, color: accentGreen, size: 12),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      message.attachment!,
                                      style: const TextStyle(
                                        color: accentGreen,
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeText,
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Reply input bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF02100C),
                border: Border(
                  top: BorderSide(color: Colors.white12, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      enabled: !supportVM.isSendingReply,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Type your reply here...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF061410),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: supportVM.isSendingReply
                        ? null
                        : () async {
                            final text = replyController.text.trim();
                            if (text.isEmpty) {
                              Helpers.showErrorSnackBar(context, "Reply cannot be empty");
                              return;
                            }
                            final success = await supportVM.addReply(widget.ticketId, text);
                            if (success) {
                              replyController.clear();
                              _scrollToBottom();
                            } else if (supportVM.replyError != null) {
                              Helpers.showErrorSnackBar(context, supportVM.replyError!);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: supportVM.isSendingReply ? Colors.grey : accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: supportVM.isSendingReply
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
