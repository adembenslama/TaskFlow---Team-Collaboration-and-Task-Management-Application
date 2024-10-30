import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';

class ControllereBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}