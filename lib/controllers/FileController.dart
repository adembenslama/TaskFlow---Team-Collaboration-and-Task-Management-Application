import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/controllers/AuthController.dart';

class FileController extends GetxController{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
 Rx<PickedFile?> _image  = Rx<PickedFile?>(null);

  UploadTask? uploadTask;
  final AuthController _auth = AuthController.instance; 
  void selectFile() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

      _image.value = image;
   

    uploadFile();
  }

  Future uploadFile() async {
    final path = 'files/${_auth.userData.value.uid}';

    final file = File(_image.value!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await users.doc(_auth.userData.value.uid).update({'pfp': urlDownload});

      _auth.userData.value.pfp = urlDownload;

  }
}