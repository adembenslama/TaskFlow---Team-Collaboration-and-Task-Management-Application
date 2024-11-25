import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final int timestamp;
  final String? replyTo;
  final String type;
  final bool edited;
  final int? editedAt;
  final String status;
  final List<String> seenBy;
  final Map<String, List<String>> reactions;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.replyTo,
    this.type = 'text',
    this.edited = false,
    this.editedAt,
    this.status = 'sending',
    this.seenBy = const [],
    this.reactions = const {},
  });

  factory ChatMessage.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: data['timestamp']?.millisecondsSinceEpoch ?? 0,
      replyTo: data['replyTo'],
      type: data['type'] ?? 'text',
      edited: data['edited'] ?? false,
      editedAt: data['editedAt']?.millisecondsSinceEpoch,
      status: data['status'] ?? 'sent',
      seenBy: List<String>.from(data['seenBy'] ?? []),
      reactions: Map<String, List<String>>.from(
        data['reactions']?.map((key, value) => 
          MapEntry(key, List<String>.from(value ?? []))) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'senderId': senderId,
    'timestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
    'replyTo': replyTo,
    'type': type,
    'edited': edited,
    'editedAt': editedAt != null ? Timestamp.fromMillisecondsSinceEpoch(editedAt!) : null,
    'status': status,
    'seenBy': seenBy,
    'reactions': reactions,
  };
}