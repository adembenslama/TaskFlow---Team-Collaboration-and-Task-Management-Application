import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/FileController.dart';
import 'package:manager/theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController authController = AuthController.instance;
  final FileController fileController = Get.put(FileController());
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: authController.userData.value.firstName);
    lastNameController = TextEditingController(text: authController.userData.value.lastName);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text("Edit Profile", style: boldTitle),
        actions: [
          IconButton(
            onPressed: () async {
               await authController.updateUserProfile(
                firstNameController.text,
                lastNameController.text,
                authController.userData.value.pfp,
              );
                Get.back();
            ;
            },
            icon: const Icon(Icons.check, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => fileController.selectAndUploadImage(),
              child: Stack(
                children: [
                  Obx(() {
                    if (fileController.isLoading.value) {
                      return const CircleAvatar(
                        radius: 50,
                        child: CircularProgressIndicator(),
                      );
                    }
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        authController.userData.value.pfp,
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: royalBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: royalBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: royalBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                    'Email: ${authController.userData.value.mail}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}