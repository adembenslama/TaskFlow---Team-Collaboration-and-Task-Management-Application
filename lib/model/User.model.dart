import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String firstName;
  String uid;
  String lastName;
  String pfp;
  List workspace  = [] ; 

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.pfp,
    required this.workspace
  });
  factory UserModel.fromJson(DocumentSnapshot json) {
    return UserModel(
      uid: json.id,
      firstName: json["firstName"],
      lastName: json["lastName"],
      pfp:
         json["pfp"],
      workspace: json["workspaces"]
      
    );
  }
}