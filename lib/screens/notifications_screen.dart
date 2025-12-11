import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
        actions: [
          StreamBuilder<int>(
            stream: _notificationService.getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(onPressed: _showNotificationSettings, icon: const Icon(Icons.settings)),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading notifications: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => setState(() {}), child: const Text('Retry')),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendTestNotification,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.notifications_active),
        label: const Text('Test Notification', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: isUnread ? 4 : 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: isUnread ? Border.all(color: const Color(0xFF4CAF50), width: 1) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getNotificationTypeDisplayName(notification.type),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getNotificationColor(notification.type),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ll receive notifications about appointments, document expiry, benefit updates, and important messages.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text(
                'Send Test Notification',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xFF2196F3);
      case NotificationType.documentExpiry:
        return const Color(0xFFFF9800);
      case NotificationType.benefitUpdate:
        return const Color(0xFF4CAF50);
      case NotificationType.chatMessage:
        return const Color(0xFFE91E63);
      case NotificationType.systemAlert:
        return const Color(0xFF9C27B0);
      case NotificationType.reminder:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.documentExpiry:
        return Icons.description;
      case NotificationType.benefitUpdate:
        return Icons.star;
      case NotificationType.chatMessage:
        return Icons.chat;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  String _getNotificationTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.documentExpiry:
        return 'Document';
      case NotificationType.benefitUpdate:
        return 'Benefits';
      case NotificationType.chatMessage:
        return 'Message';
      case NotificationType.systemAlert:
        return 'Alert';
      case NotificationType.reminder:
        return 'Reminder';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(AppNotification notification) async {
    // Mark as read if unread
    if (!notification.isRead) {
      await _notificationService.markNotificationAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.documentExpiry:
        // Navigate to documents screen
        break;
      case NotificationType.chatMessage:
        // Navigate to chat screen
        break;
      case NotificationType.appointment:
        // Navigate to appointments screen
        break;
      case NotificationType.benefitUpdate:
        // Navigate to benefits screen
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                const SizedBox(height: 16),
                Text(
                  'Received: ${_formatFullDate(notification.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (notification.data != null && notification.data!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Additional Information:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...notification.data!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
    );
  }

  String _formatFullDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _markAllAsRead() async {
    final success = await _notificationService.markAllNotificationsAsRead();
    if (mounted) {
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

  Future<void> _sendTestNotification() async {
    final testNotifications = [
      {
        'title': 'Appointment Reminder',
        'body': 'You have an appointment with Dr. Smith tomorrow at 2:00 PM.',
        'type': NotificationType.appointment,
      },
      {
        'title': 'Document Expiring Soon',
        'body': 'Your VA ID card will expire in 7 days. Please renew it soon.',
        'type': NotificationType.documentExpiry,
      },
      {
        'title': 'Benefit Update',
        'body': 'Your disability claim status has been updated. Check your dashboard for details.',
        'type': NotificationType.benefitUpdate,
      },
      {
        'title': 'New Message',
        'body': 'You have a new message from Veterans Support Team.',
        'type': NotificationType.chatMessage,
      },
    ];

    final randomNotification = testNotifications[DateTime.now().millisecond % testNotifications.length];

    final success = await _notificationService.sendCustomNotification(
      title: randomNotification['title'] as String,
      body: randomNotification['body'] as String,
      type: randomNotification['type'] as NotificationType,
      data: {'isTest': true, 'sentAt': DateTime.now().toIso8601String()},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test notification sent!' : 'Failed to send test notification'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose which notifications you want to receive:'),
                const SizedBox(height: 16),
                _buildSettingTile('Appointment Reminders', true),
                _buildSettingTile('Document Expiry Alerts', true),
                _buildSettingTile('Benefit Updates', true),
                _buildSettingTile('Chat Messages', true),
                _buildSettingTile('System Alerts', true),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Widget _buildSettingTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: (bool newValue) {
        // Handle setting change
      },
      activeThumbColor: const Color(0xFF4CAF50),
      contentPadding: EdgeInsets.zero,
    );
  }
}
