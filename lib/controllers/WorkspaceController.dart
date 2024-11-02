import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/workspace.dart';

class WorkSpaceController extends GetxController {
  RxList<Workspace> workspaces = <Workspace>[].obs;
    static WorkSpaceController instance = Get.find();

  RxBool isLoading = true.obs;
    getIsLoading() => isLoading.value;
    getWorkspaces() => workspaces;
    Rx<Workspace> selectedWorkSpace = Workspace(name: "null", uid: "null", members: []).obs ;
    final AuthController _authController = AuthController.instance ;

@override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchWorkspaces(_authController.userData.value.workspace);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user workspaces based on workspace IDs from userData
  Future<void> fetchWorkspaces(List<dynamic> workspaceIds) async {
      isLoading(true);
    
    print("staaaaaaaaaaaaaaaaaaaaaaaaaaaarting");
   
    try {
      List<Workspace> fetchedWorkspaces = [];

      // Loop through each workspace ID and fetch data
      for (String workspaceId in workspaceIds) {
                

        final workspaceDoc = await _firestore.collection('workspaces').doc(workspaceId).get();
        if (workspaceDoc.exists) {
          String workspaceName = workspaceDoc.data()?['name'] ?? '';
          List<Member> members = [];

          // Fetch members in the subcollection `users` within each workspace
          final membersSnapshot = await _firestore
              .collection('workspaces')
              .doc(workspaceId)
              .collection('users')
              .get();

          for (var memberDoc in membersSnapshot.docs) {
            members.add(Member.fromJson(memberDoc));
          }
      print('almost theeeeeeeeeeeeeeeerrrrrrrrrrrrrrrrreeeeeeeeeeeeee');
          // Create a Workspace object and add it to the list
          fetchedWorkspaces.add(
            Workspace(uid: workspaceId, name: workspaceName, members: members),
          );
      
          print(workspaceName);
        }
      }

      // Update the observable list with fetched workspaces
      workspaces.assignAll(fetchedWorkspaces);
    } catch (e) {
      print("Error fetching workspaces: $e");
    } finally {
      isLoading(false);
    }
  }
}