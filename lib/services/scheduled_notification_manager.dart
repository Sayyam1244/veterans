import 'package:flutter/foundation.dart';
import 'dart:async';
import 'notification_service.dart';
import 'document_service.dart';

class ScheduledNotificationManager {
  static final ScheduledNotificationManager _instance = ScheduledNotificationManager._internal();
  factory ScheduledNotificationManager() => _instance;
  ScheduledNotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  final DocumentService _documentService = DocumentService();

  Timer? _documentExpiryTimer;
  Timer? _cleanupTimer;
  bool _isRunning = false;

  // Start the scheduled notification manager
  void start() {
    if (_isRunning) return;

    _isRunning = true;

    // Check for document expiry notifications every 24 hours
    _documentExpiryTimer = Timer.periodic(const Duration(hours: 24), (_) => _checkDocumentExpiry());

    // Clean up old notifications every 7 days
    _cleanupTimer = Timer.periodic(const Duration(days: 7), (_) => _cleanupOldNotifications());

    // Run initial checks
    _checkDocumentExpiry();

    if (kDebugMode) {
      print('ScheduledNotificationManager started');
    }
  }

  // Stop the scheduled notification manager
  void stop() {
    _documentExpiryTimer?.cancel();
    _cleanupTimer?.cancel();
    _isRunning = false;

    if (kDebugMode) {
      print('ScheduledNotificationManager stopped');
    }
  }

  // Check for documents expiring soon and send notifications
  Future<void> _checkDocumentExpiry() async {
    try {
      final currentUser = _documentService.currentUser;
      if (currentUser == null) return;

      // Get documents expiring in the next 30 days
      final documents = await _documentService.getUserDocuments().first;
      final now = DateTime.now();

      for (final document in documents) {
        if (document.expiryDate == null) continue;

        final daysUntilExpiry = document.expiryDate!.difference(now).inDays;

        // Send notification for documents expiring in 30 days
        if (daysUntilExpiry == 30) {
          await _notificationService.sendCustomNotification(
            title: 'Document Expiring Soon',
            body: 'Your ${document.name} will expire in 30 days.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': document.id,
              'documentName': document.name,
              'expiryDate': document.expiryDate!.toIso8601String(),
              'daysUntilExpiry': daysUntilExpiry,
            },
          );
        }

        // Send notification for documents expiring in 7 days
        if (daysUntilExpiry == 7) {
          await _notificationService.sendCustomNotification(
            title: 'Document Expiring This Week',
            body: 'Your ${document.name} will expire in 7 days. Please renew it soon.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': document.id,
              'documentName': document.name,
              'expiryDate': document.expiryDate!.toIso8601String(),
              'daysUntilExpiry': daysUntilExpiry,
              'urgent': true,
            },
          );
        }

        // Send notification for documents expiring in 1 day
        if (daysUntilExpiry == 1) {
          await _notificationService.sendCustomNotification(
            title: 'Document Expires Tomorrow',
            body: 'URGENT: Your ${document.name} expires tomorrow! Please renew it immediately.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': document.id,
              'documentName': document.name,
              'expiryDate': document.expiryDate!.toIso8601String(),
              'daysUntilExpiry': daysUntilExpiry,
              'urgent': true,
              'critical': true,
            },
          );
        }

        // Send notification for expired documents
        if (daysUntilExpiry == 0) {
          await _notificationService.sendCustomNotification(
            title: 'Document Expired',
            body: 'Your ${document.name} has expired today. Please renew it as soon as possible.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': document.id,
              'documentName': document.name,
              'expiryDate': document.expiryDate!.toIso8601String(),
              'daysUntilExpiry': daysUntilExpiry,
              'expired': true,
              'critical': true,
            },
          );
        }
      }

      if (kDebugMode) {
        print('Document expiry check completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking document expiry: $e');
      }
    }
  }

  // Clean up old notifications
  Future<void> _cleanupOldNotifications() async {
    try {
      await _notificationService.cleanupOldNotifications();

      if (kDebugMode) {
        print('Old notifications cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old notifications: $e');
      }
    }
  }

  // Send welcome notification to new users
  Future<void> sendWelcomeNotification() async {
    try {
      await _notificationService.sendCustomNotification(
        title: 'Welcome to Veterans Support',
        body: 'Thank you for joining! Explore resources, upload documents, and get support.',
        type: NotificationType.systemAlert,
        data: {'isWelcome': true, 'version': '1.0.0'},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending welcome notification: $e');
      }
    }
  }

  // Send reminder notifications for important tasks
  Future<void> sendTaskReminder({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _notificationService.sendCustomNotification(
        title: title,
        body: body,
        type: NotificationType.reminder,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending task reminder: $e');
      }
    }
  }

  // Send benefit update notifications
  Future<void> sendBenefitUpdate({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _notificationService.sendCustomNotification(
        title: title,
        body: body,
        type: NotificationType.benefitUpdate,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending benefit update: $e');
      }
    }
  }

  // Send system alert notifications
  Future<void> sendSystemAlert({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _notificationService.sendCustomNotification(
        title: title,
        body: body,
        type: NotificationType.systemAlert,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending system alert: $e');
      }
    }
  }

  // Send chat message notification
  Future<void> sendChatMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    try {
      await _notificationService.sendCustomNotification(
        title: 'New message from $senderName',
        body: message,
        type: NotificationType.chatMessage,
        data: {'conversationId': conversationId, 'senderName': senderName, 'messagePreview': message},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending chat message notification: $e');
      }
    }
  }

  // Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String appointmentTitle,
    required DateTime appointmentDate,
    required String location,
    Duration reminderBefore = const Duration(hours: 24),
  }) async {
    try {
      final reminderTime = appointmentDate.subtract(reminderBefore);

      if (reminderTime.isAfter(DateTime.now())) {
        await _notificationService.sendCustomNotification(
          title: 'Appointment Reminder',
          body: 'You have "$appointmentTitle" scheduled for tomorrow at ${_formatTime(appointmentDate)}.',
          type: NotificationType.appointment,
          scheduledAt: reminderTime,
          data: {
            'appointmentTitle': appointmentTitle,
            'appointmentDate': appointmentDate.toIso8601String(),
            'location': location,
            'reminderType': 'appointment',
          },
        );
      }

      // Also schedule a 1-hour reminder
      final oneHourReminder = appointmentDate.subtract(const Duration(hours: 1));
      if (oneHourReminder.isAfter(DateTime.now())) {
        await _notificationService.sendCustomNotification(
          title: 'Appointment Starting Soon',
          body: 'Your "$appointmentTitle" appointment starts in 1 hour at $location.',
          type: NotificationType.appointment,
          scheduledAt: oneHourReminder,
          data: {
            'appointmentTitle': appointmentTitle,
            'appointmentDate': appointmentDate.toIso8601String(),
            'location': location,
            'reminderType': 'urgent',
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling appointment reminder: $e');
      }
    }
  }

  // Get notification statistics
  Future<Map<String, int>> getNotificationStats() async {
    try {
      final notifications = await _notificationService.getUserNotifications().first;

      final stats = <String, int>{
        'total': notifications.length,
        'unread': notifications.where((n) => !n.isRead).length,
        'appointment': notifications.where((n) => n.type == NotificationType.appointment).length,
        'documentExpiry': notifications.where((n) => n.type == NotificationType.documentExpiry).length,
        'benefitUpdate': notifications.where((n) => n.type == NotificationType.benefitUpdate).length,
        'chatMessage': notifications.where((n) => n.type == NotificationType.chatMessage).length,
        'systemAlert': notifications.where((n) => n.type == NotificationType.systemAlert).length,
        'reminder': notifications.where((n) => n.type == NotificationType.reminder).length,
      };

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notification stats: $e');
      }
      return {};
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour == 0
            ? 12
            : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Dispose resources
  void dispose() {
    stop();
  }
}
