import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/controllers/AuthController.dart';

class FileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _auth = AuthController.instance;
  
  final RxBool isLoading = false.obs;
  final Rx<String?> selectedFileUrl = Rx<String?>(null);

  Future<void> selectAndUploadImage() async {
    try {
      isLoading(true);
      
      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return;

      // Upload image
      final path = 'profiles/${_auth.userData.value.uid}/${DateTime.now().millisecondsSinceEpoch}';
      final file = File(image.path);
      final ref = _storage.ref().child(path);
      
      // Upload and get URL
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      
      // Update user profile
      await _firestore
          .collection('users')
          .doc(_auth.userData.value.uid)
          .update({'pfp': urlDownload});

      // Update local state
      selectedFileUrl.value = urlDownload;
      _auth.userData.update((user) {
        if (user != null) {
          user.pfp = urlDownload;
        }
      });

      Get.snackbar('Success', 'Profile picture updated successfully');
    } catch (e) {
      print('Error uploading image: $e');
      Get.snackbar('Error', 'Failed to update profile picture');
    } finally {
      isLoading(false);
    }
  }
}