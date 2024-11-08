
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _handleNotificationTap(details);
      },
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token'); // Save this token to your user's document

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground Message: ${message.data}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  void _handleNotificationTap(NotificationResponse details) {
    if (details.payload != null) {
      // Handle notification tap based on payload
      // Example: Navigate to specific screen
      final data = details.payload!;
      _handleNotificationNavigation(data);
    }
  }

  void _handleBackgroundNotificationTap(RemoteMessage message) {
    // Handle notification tap when app is in background
    _handleNotificationNavigation(message.data.toString());
  }

  void _handleNotificationNavigation(String data) {
    // Example navigation based on notification type
    if (data.contains('chat')) {
      // Navigate to chat
      Get.toNamed('/chat');
    } else if (data.contains('task')) {
      // Navigate to task
      Get.toNamed('/tasks');
    }
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background Message: ${message.data}');
}