import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String workspaceId;
  final String createdBy;
  final List<String> assignedTo;
  final DateTime startTime;
  final DateTime endTime;
  final String color; // 'blue', 'yellow', 'red'
  final bool isRepeat;
  final String repeatType; // 'Daily', 'Weekly', 'Monthly'
  final List<int> repeatDays; // For weekly repeat [1,3,5] = Mon,Wed,Fri
  final DateTime? repeatUntil;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.workspaceId,
    required this.createdBy,
    required this.assignedTo,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isRepeat = false,
    this.repeatType = '',
    this.repeatDays = const [],
    this.repeatUntil,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Task.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      assignedTo: List<String>.from(data['assignedTo'] ?? []),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      color: data['color'] ?? 'blue',
      isRepeat: data['isRepeat'] ?? false,
      repeatType: data['repeatType'] ?? '',
      repeatDays: List<int>.from(data['repeatDays'] ?? []),
      repeatUntil: data['repeatUntil'] != null 
          ? (data['repeatUntil'] as Timestamp).toDate() 
          : null,
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'workspaceId': workspaceId,
    'createdBy': createdBy,
    'assignedTo': assignedTo,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'color': color,
    'isRepeat': isRepeat,
    'repeatType': repeatType,
    'repeatDays': repeatDays,
    'repeatUntil': repeatUntil != null ? Timestamp.fromDate(repeatUntil!) : null,
    'isCompleted': isCompleted,
    'createdAt': Timestamp.fromDate(createdAt),
  };
} 
