import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/controllers/TaskController.dart';
import 'package:manager/controllers/WorkspaceController.dart';

class ControllereBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<WorkSpaceController>(WorkSpaceController(), permanent: true);
    Get.put<TaskController>(TaskController(), permanent: true);
    Get.put(ChatController()); // Add this line
  }
}
