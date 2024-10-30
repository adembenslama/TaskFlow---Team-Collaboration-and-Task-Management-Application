import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String firstName;
  String uid;
  String lastName;
  String pfp;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.pfp,
  });
  factory UserModel.fromJson(DocumentSnapshot json) {
    return UserModel(
      uid: json.id,
      firstName: json["firstName"],
      lastName: json["lastName"],
      pfp:
         json["pfp"],
    );
  }
}