import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/FeedController.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/notification.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatelessWidget {
  final FeedController _feedController = Get.find();
  final AuthController _authController = Get.find();

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _feedController.getNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationTile(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    String message = '';
    IconData icon;
    
    switch (notification.type) {
      case 'comment':
        message = 'commented on your post';
        icon = Iconsax.message;
        break;
      case 'reply':
        message = 'replied to your comment';
        icon = Iconsax.message_text;
        break;
      default:
        message = 'interacted with your post';
        icon = Iconsax.notification;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead ? Colors.grey : royalBlue,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        '${_authController.getUserName(notification.triggeredBy)} $message',
      ),
      subtitle: Text(
        timeago.format(notification.createdAt),
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () {
        _feedController.markNotificationAsRead(notification.id);
        // Navigate to the post
        // TODO: Implement navigation to specific post
      },
    );
  }
} 