import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/FileController.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController  authController = AuthController.instance;
    FileController fileController = Get.put(FileController());

    return  Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Edit Profile Page"),
      ),
      body: GestureDetector(
        onTap: (){
          fileController.selectFile();
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(authController.userData.value.pfp),
        ),
      ),
    );
  }
}