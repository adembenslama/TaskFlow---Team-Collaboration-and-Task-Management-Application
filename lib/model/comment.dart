import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final String? replyTo;  // ID of parent comment if this is a reply

  Comment({
    required this.id,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.replyTo,
  });

  factory Comment.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      content: data['content'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      replyTo: data['replyTo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'replyTo': replyTo,
  };
}