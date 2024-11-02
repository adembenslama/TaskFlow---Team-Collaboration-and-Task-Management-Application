import 'package:cloud_firestore/cloud_firestore.dart';



class Workspace {
  String uid;
  String name;
  List<Member> members;

  Workspace({
    required this.name,
    required this.uid,
    required this.members,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'members': members.map((member) => member.toJson()).toList(),
      };
}



class Member {
  String uid;
  String role;
  DateTime inTime;

  Member({
    required this.uid,
    required this.role,
    required this.inTime,
  });

  factory Member.fromJson(DocumentSnapshot doc) {
    return Member(
      uid: doc.id,
      role: doc['role'] ?? '',
      inTime: (doc['EnterDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role,
        'EntryDate': inTime.toIso8601String(),
      };
}