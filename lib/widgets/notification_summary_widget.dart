import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/scheduled_notification_manager.dart';
import '../screens/notifications_screen.dart';

class NotificationSummaryWidget extends StatelessWidget {
  const NotificationSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();
    final ScheduledNotificationManager notificationManager = ScheduledNotificationManager();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, color: Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                ),
              ),
              StreamBuilder<int>(
                stream: notificationService.getUnreadNotificationsCount(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  if (unreadCount > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification stats
          FutureBuilder<Map<String, int>>(
            future: notificationManager.getNotificationStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              final stats = snapshot.data ?? {};
              final total = stats['total'] ?? 0;
              final unread = stats['unread'] ?? 0;

              return Column(
                children: [
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.email,
                        label: 'Total',
                        value: total.toString(),
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        icon: Icons.mark_email_unread,
                        label: 'Unread',
                        value: unread.toString(),
                        color: const Color(0xFFE91E63),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: unread > 0 ? () => _markAllAsRead(context) : null,
                          icon: const Icon(Icons.done_all, size: 16, color: Colors.white),
                          label: const Text(
                            'Mark Read',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: unread > 0 ? const Color(0xFF4CAF50) : Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    final notificationService = NotificationService();
    final success = await notificationService.markAllNotificationsAsRead();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'All notifications marked as read' : 'Failed to mark notifications as read',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
