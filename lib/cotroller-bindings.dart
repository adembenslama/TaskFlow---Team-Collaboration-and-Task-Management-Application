import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/WorkspaceController.dart';

class ControllereBindings extends Bindings {
  @override
  void dependencies() {
    
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<WorkSpaceController>(WorkSpaceController(), permanent: true);
  }
}