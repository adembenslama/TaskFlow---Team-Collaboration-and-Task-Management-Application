import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String content;
  final String workspaceId;
  final String createdBy;
  final DateTime createdAt;
  final List<String> images;
  final List<String> likes;
  final bool isPinned;
  final String? linkedTaskId;
  final int commentCount;

  Post({
    required this.id,
    required this.content,
    required this.workspaceId,
    required this.createdBy,
    required this.createdAt,
    this.images = const [],
    this.likes = const [],
    this.isPinned = false,
    this.linkedTaskId,
    this.commentCount = 0,
  });

  factory Post.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      content: data['content'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      images: List<String>.from(data['images'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      isPinned: data['isPinned'] ?? false,
      linkedTaskId: data['linkedTaskId'],
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'workspaceId': workspaceId,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'images': images,
    'likes': likes,
    'isPinned': isPinned,
    'linkedTaskId': linkedTaskId,
    'commentCount': commentCount,
  };
}
