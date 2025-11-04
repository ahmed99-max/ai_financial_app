// lib/providers/notification_provider.dart
// Notification management with FCM and local notifications

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'alert', 'offer', 'reminder', 'payment', 'investment'
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
        'image_url': imageUrl,
      };

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'alert',
      data: map['data'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isRead: map['is_read'] ?? false,
      imageUrl: map['image_url'],
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _fcmInitialized = false;
  String? _fcmToken;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get fcmInitialized => _fcmInitialized;
  String? get fcmToken => _fcmToken;

  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      // Request FCM permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _fcm.getToken();

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Listen for background message taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      }

      // Initialize local notifications
      await _initializeTimezones();
      await _initializeLocalNotifications();

      _fcmInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  // Initialize timezones for scheduled notifications
  Future<void> _initializeTimezones() async {
    tz.initializeTimeZones();
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'alert',
      data: message.data,
      timestamp: DateTime.now(),
      imageUrl: message.notification?.apple?.imageUrl ??
          message.notification?.android?.imageUrl,
    );

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();

    // Show local notification
    _showLocalNotification(notification);
  }

  // Handle message opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    final notification = NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'alert',
      data: message.data,
      timestamp: DateTime.now(),
      isRead: true,
    );

    // Handle notification tap action
    if (message.data['type'] == 'payment') {
      // Navigate to payment details
    } else if (message.data['type'] == 'investment') {
      // Navigate to investment
    } else if (message.data['type'] == 'offer') {
      // Navigate to offers
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // Handle notification action based on payload
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(NotificationItem notification) async {
    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Notifications for AI Finance app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
          color: Colors.blue,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: notification.id,
    );
  }

  // Send local notification (for reminders, etc.)
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    await _showLocalNotification(notification);
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required String type,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      timestamp: scheduledTime,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      notification.id.hashCode,
      title,
      body,
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled notifications for reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.id,
    );
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = NotificationItem(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          data: notification.data,
          timestamp: notification.timestamp,
          isRead: true,
          imageUrl: notification.imageUrl,
        );
        _unreadCount--;
        notifyListeners();
      }
    }
  }

  // Mark all as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) {
      if (n.isRead) return n;
      return NotificationItem(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        data: n.data,
        timestamp: n.timestamp,
        isRead: true,
        imageUrl: n.imageUrl,
      );
    }).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => NotificationItem(
        id: '',
        title: '',
        body: '',
        type: '',
        timestamp: DateTime.now(),
      ),
    );

    if (notification.id.isNotEmpty) {
      _notifications.removeWhere((n) => n.id == notificationId);
      if (!notification.isRead) {
        _unreadCount--;
      }
      notifyListeners();
    }
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationItem> getByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationItem> getUnread() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Enable/disable notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (enabled) {
      await initializeNotifications();
    } else {
      await _localNotifications.cancelAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
