import 'package:cloud_firestore/cloud_firestore.dart';

class ChatChannel {
  final String id;
  final String name;
  final String workspaceId;
  final String type; // 'channel' or 'direct'
  final List<String> members;
  final DateTime createdAt;
  final String createdBy;

  ChatChannel({
    required this.id,
    required this.name,
    required this.workspaceId,
    required this.type,
    required this.members,
    required this.createdAt,
    required this.createdBy,
  });

  factory ChatChannel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatChannel(
      id: doc.id,
      name: data['name'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      type: data['type'] ?? 'channel',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'workspaceId': workspaceId,
    'type': type,
    'members': members,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
  };
} 