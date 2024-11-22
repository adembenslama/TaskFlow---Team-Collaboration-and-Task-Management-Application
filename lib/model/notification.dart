import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type; // 'comment', 'reply', 'like'
  final String userId; // User who should receive the notification
  final String triggeredBy; // User who triggered the notification
  final String postId;
  final String? commentId;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.triggeredBy,
    required this.postId,
    this.commentId,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      type: data['type'] ?? '',
      userId: data['userId'] ?? '',
      triggeredBy: data['triggeredBy'] ?? '',
      postId: data['postId'] ?? '',
      commentId: data['commentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'userId': userId,
    'triggeredBy': triggeredBy,
    'postId': postId,
    'commentId': commentId,
    'createdAt': createdAt,
    'isRead': isRead,
  };
} 