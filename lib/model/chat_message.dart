 import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final String? replyTo;
  final String type;
  final bool? edited;
  final DateTime? editedAt;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.replyTo,
    required this.type,
    this.edited,
    this.editedAt,
  });

  factory ChatMessage.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      replyTo: data['replyTo'],
      type: data['type'] ?? 'text',
      edited: data['edited'],
      editedAt: data['editedAt'] != null 
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'senderId': senderId,
    'timestamp': Timestamp.fromDate(timestamp),
    'replyTo': replyTo,
    'type': type,
    'edited': edited,
    'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
  };
}