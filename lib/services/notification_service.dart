import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

enum NotificationType { appointment, documentExpiry, benefitUpdate, chatMessage, systemAlert, reminder }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? scheduledAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.scheduledAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.systemAlert,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      data: data['data'],
      scheduledAt: data['scheduledAt'] != null ? (data['scheduledAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Request permissions
      await _requestPermissions();

      // Get and save FCM token
      await _saveFCMToken();

      _isInitialized = true;

      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Request permissions
  Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    final messagingSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('Messaging permission status: ${messagingSettings.authorizationStatus}');
    }

    // Request local notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMToken() async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(currentUserId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          print('FCM Token saved: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _firestore.collection('users').doc(currentUserId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    });
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    // Show local notification for foreground messages
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );

    // Save notification to Firestore
    _saveNotificationToFirestore(message);
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
    }

    // Handle navigation based on notification type
    _navigateFromNotification(message.data);
  }

  // Show local notification
  Future<void> _showLocalNotification({required String title, required String body, String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'veteranns_notifications',
      'Veteranns Notifications',
      channelDescription: 'Notifications for Veterans Support App',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final notification = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        type: _getNotificationTypeFromData(message.data),
        createdAt: DateTime.now(),
        data: message.data,
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification: $e');
      }
    }
  }

  // Get notification type from data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString != null) {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => NotificationType.systemAlert,
      );
    }
    return NotificationType.systemAlert;
  }

  // Handle notification tap from local notifications
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromNotification(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing notification payload: $e');
        }
      }
    }
  }

  // Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    // This would be implemented based on your navigation setup
    // For now, we'll just print the data
    if (kDebugMode) {
      print('Navigate from notification: $data');
    }
  }

  // Get user notifications stream
  Stream<List<AppNotification>> getUserNotifications() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final batch = _firestore.batch();
      final notifications =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('notifications')
              .where('isRead', isEqualTo: false)
              .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      return false;
    }
  }

  // Send custom notification (for testing or admin use)
  Future<bool> sendCustomNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
  }) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
        data: data,
        scheduledAt: scheduledAt,
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toFirestore());

      // Show local notification immediately if not scheduled
      if (scheduledAt == null) {
        await _showLocalNotification(title: title, body: body, payload: jsonEncode(data ?? {}));
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending custom notification: $e');
      }
      return false;
    }
  }

  // Schedule document expiry notifications
  Future<void> scheduleDocumentExpiryNotifications() async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final documentsSnapshot =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('documents')
              .where('expiryDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
              .get();

      for (final doc in documentsSnapshot.docs) {
        final data = doc.data();
        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        final documentName = data['name'] as String;

        // Schedule notification 30 days before expiry
        final notificationDate = expiryDate.subtract(const Duration(days: 30));
        if (notificationDate.isAfter(DateTime.now())) {
          await sendCustomNotification(
            title: 'Document Expiring Soon',
            body: 'Your document "$documentName" will expire in 30 days.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': doc.id,
              'documentName': documentName,
              'expiryDate': expiryDate.toIso8601String(),
            },
            scheduledAt: notificationDate,
          );
        }

        // Schedule notification 7 days before expiry
        final urgentNotificationDate = expiryDate.subtract(const Duration(days: 7));
        if (urgentNotificationDate.isAfter(DateTime.now())) {
          await sendCustomNotification(
            title: 'Document Expiring This Week',
            body: 'Your document "$documentName" will expire in 7 days. Please renew it soon.',
            type: NotificationType.documentExpiry,
            data: {
              'documentId': doc.id,
              'documentName': documentName,
              'expiryDate': expiryDate.toIso8601String(),
              'urgent': true,
            },
            scheduledAt: urgentNotificationDate,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling document expiry notifications: $e');
      }
    }
  }

  // Clean up old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('notifications')
              .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
              .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old notifications: $e');
      }
    }
  }

  // Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Received background message: ${message.messageId}');
  }
}
