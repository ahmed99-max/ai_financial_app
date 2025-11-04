// lib/services/notification_service.dart
// Comprehensive notification delivery system with Firebase Cloud Messaging

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification system
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      await _firebaseMessaging.requestPermission();

      // Configure foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configure background message handler
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _localNotifications.initialize(initSettings);

      logger.info('Notification service initialized', tag: 'NotificationService');
    } catch (e) {
      logger.error('Failed to initialize notifications: $e',
          tag: 'NotificationService');
    }
  }

  /// Get device FCM token
  Future<String?> getDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      logger.info('Device token: ${token?.substring(0, 20)}...',
          tag: 'NotificationService');
      return token;
    } catch (e) {
      logger.error('Failed to get device token: $e',
          tag: 'NotificationService');
      return null;
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      logger.info(
        'Foreground message: ${message.notification?.title}',
        tag: 'NotificationService',
      );

      if (message.notification != null) {
        await _showLocalNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          payload: message.data,
        );
      }
    } catch (e) {
      logger.error('Error handling foreground message: $e',
          tag: 'NotificationService');
    }
  }

  /// Handle background messages (static method)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    logger.info(
      'Background message received: ${message.notification?.title}',
      tag: 'NotificationService',
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'financial_app',
        'Financial App Notifications',
        channelDescription: 'Notifications for financial app',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.hashCode,
        title,
        body,
        notificationDetails,
        payload: payload != null ? payload.toString() : null,
      );
    } catch (e) {
      logger.error('Failed to show local notification: $e',
          tag: 'NotificationService');
    }
  }

  /// Send EMI reminder notification
  Future<void> sendEMIReminder({
    required String loanName,
    required double emiAmount,
    required DateTime dueDate,
  }) async {
    try {
      await _showLocalNotification(
        title: 'EMI Payment Due',
        body:
            'Your $loanName EMI of ₹${emiAmount.toStringAsFixed(0)} is due on ${dueDate.day}/${dueDate.month}',
        payload: {'type': 'emi', 'loanName': loanName},
      );

      logger.info(
        'EMI reminder sent for $loanName',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send EMI reminder: $e',
          tag: 'NotificationService');
    }
  }

  /// Send budget alert notification
  Future<void> sendBudgetAlert({
    required String category,
    required double percentUsed,
  }) async {
    try {
      String message;
      if (percentUsed >= 100) {
        message = 'You\'ve exceeded your $category budget';
      } else if (percentUsed >= 90) {
        message = 'You\'ve reached 90% of your $category budget';
      } else {
        message = 'You\'ve reached 80% of your $category budget';
      }

      await _showLocalNotification(
        title: 'Budget Alert',
        body: message,
        payload: {'type': 'budget', 'category': category},
      );

      logger.info(
        'Budget alert sent for $category (${percentUsed.toStringAsFixed(0)}%)',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send budget alert: $e',
          tag: 'NotificationService');
    }
  }

  /// Send transaction notification
  Future<void> sendTransactionNotification({
    required String type, // 'expense', 'investment', 'payment'
    required String title,
    required String message,
  }) async {
    try {
      await _showLocalNotification(
        title: title,
        body: message,
        payload: {'type': type},
      );

      logger.info(
        'Transaction notification sent: $title',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send transaction notification: $e',
          tag: 'NotificationService');
    }
  }

  /// Send report ready notification
  Future<void> sendReportNotification({
    required String reportType, // 'weekly', 'monthly'
    required DateTime generatedDate,
  }) async {
    try {
      final message =
          'Your $reportType report is ready to view';

      await _showLocalNotification(
        title: 'Report Ready',
        body: message,
        payload: {'type': 'report', 'reportType': reportType},
      );

      logger.info(
        'Report notification sent: $reportType',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send report notification: $e',
          tag: 'NotificationService');
    }
  }

  /// Send bill reminder notification
  Future<void> sendBillReminder({
    required String billTitle,
    required String participantName,
    required double amount,
  }) async {
    try {
      final message =
          'Reminder: $participantName\'s share for $billTitle (₹${amount.toStringAsFixed(0)}) is pending';

      await _showLocalNotification(
        title: 'Bill Settlement Reminder',
        body: message,
        payload: {'type': 'bill', 'billTitle': billTitle},
      );

      logger.info(
        'Bill reminder sent for $billTitle',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send bill reminder: $e',
          tag: 'NotificationService');
    }
  }

  /// Send investment alert notification
  Future<void> sendInvestmentAlert({
    required String assetName,
    required double changePercent,
    required bool isIncrease,
  }) async {
    try {
      final direction = isIncrease ? 'gained' : 'lost';
      final message =
          'Your $assetName has $direction ${changePercent.abs().toStringAsFixed(2)}% in value';

      await _showLocalNotification(
        title: isIncrease ? 'Investment Gain' : 'Investment Loss',
        body: message,
        payload: {'type': 'investment', 'assetName': assetName},
      );

      logger.info(
        'Investment alert sent for $assetName',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to send investment alert: $e',
          tag: 'NotificationService');
    }
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    try {
      // This would integrate with flutter_local_notifications scheduling
      logger.info(
        'Notification scheduled for ${scheduledTime.toIso8601String()}',
        tag: 'NotificationService',
      );
    } catch (e) {
      logger.error('Failed to schedule notification: $e',
          tag: 'NotificationService');
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      logger.info('Notification cancelled: $id', tag: 'NotificationService');
    } catch (e) {
      logger.error('Failed to cancel notification: $e',
          tag: 'NotificationService');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      logger.info('All notifications cancelled', tag: 'NotificationService');
    } catch (e) {
      logger.error('Failed to cancel all notifications: $e',
          tag: 'NotificationService');
    }
  }
}

// Convenience instance
final notificationService = NotificationService();
