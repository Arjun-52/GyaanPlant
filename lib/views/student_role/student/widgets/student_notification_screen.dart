import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/student_viewmodel/notification_viewmodel.dart';
import '../../../../models/notification/notification_model.dart';

class StudentNotificationScreen extends StatefulWidget {
  const StudentNotificationScreen({super.key});

  @override
  State<StudentNotificationScreen> createState() =>
      _StudentNotificationScreenState();
}

class _StudentNotificationScreenState extends State<StudentNotificationScreen> {
  late NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<NotificationViewModel>(context, listen: false);
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06130F), // dark greenish bg
      appBar: AppBar(
        backgroundColor: const Color(0xFF06130F),
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              return TextButton(
                onPressed: viewModel.unreadCount > 0 && !viewModel.isLoading
                    ? () => viewModel.markAllAsRead()
                    : null,
                child: Text(
                  "MARK ALL",
                  style: TextStyle(
                    color: viewModel.unreadCount > 0 && !viewModel.isLoading
                        ? const Color(0xFF00E676)
                        : Colors.white24,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _viewModel.refreshNotifications();
        },
        color: const Color(0xFF00E676),
        child: Consumer<NotificationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                ),
              );
            }

            if (viewModel.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.retry(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!viewModel.hasNotifications) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We\'ll notify you when something important happens',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Subtitle
                  Text(
                    "${viewModel.unreadCount} new alerts require your attention",
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 20),

                  /// Notifications list
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = viewModel.notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () =>
                              viewModel.markNotificationAsRead(notification.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          ///  Gradient like your design
          gradient: LinearGradient(
            colors: notification.read
                ? [const Color(0xFF0B2A1E), const Color(0xFF0F3D2E)]
                : [const Color(0xFF0D3A2A), const Color(0xFF114A3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          /// Glow effect
          boxShadow: [
            BoxShadow(
              color: notification.read
                  ? Colors.green.withOpacity(0.05)
                  : Colors.green.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon with glow
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.read
                    ? const Color(0xFF00E676).withOpacity(0.1)
                    : const Color(0xFF00E676).withOpacity(0.15),
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: notification.read
                    ? const Color(0xFF00E676).withOpacity(0.6)
                    : const Color(0xFF00E676),
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: notification.read ? Colors.white70 : Colors.white,
                      fontWeight: notification.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    notification.message,
                    style: TextStyle(
                      color: notification.read
                          ? Colors.white54
                          : Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        notification.formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        notification.readStatusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: notification.read
                              ? const Color(0xFF00E676).withOpacity(0.7)
                              : const Color(0xFF00E676),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate icon based on notification type
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
      case 'level_up':
        return Icons.celebration;
      case 'course':
      case 'learning':
        return Icons.school;
      case 'job':
      case 'career':
        return Icons.work;
      case 'mentor':
        return Icons.person;
      case 'payment':
        return Icons.payment;
      case 'system':
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }
}
