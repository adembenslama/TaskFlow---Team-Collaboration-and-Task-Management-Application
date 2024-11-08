import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/model/workspace.dart';

class WorkSpaceController extends GetxController {
  static WorkSpaceController instance = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  // Observables
  RxList<Workspace> workspaces = <Workspace>[].obs;
  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingUsers = false.obs;
  Rx<Workspace> selectedWorkSpace = Workspace(name: "null", uid: "null", members: []).obs;

  // Getters
  bool get getIsLoading => isLoading.value;
  bool get getIsLoadingUser => isLoadingUsers.value;
  List<Workspace> get getWorkspaces => workspaces;
  List<UserModel> get getUsers => users;
  Workspace get getSelectedWorkSpace => selectedWorkSpace.value;

  @override
  void onInit() {
    super.onInit();
    fetchWorkspaces(_authController.userData.value.workspace);
  }

  // Create new workspace
  Future<void> createWorkspace(String name) async {
    try {
      isLoading(true);
      
      // Create workspace document
      DocumentReference workspaceRef = await _firestore.collection('workspaces').add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _authController.userData.value.uid,
      });

      // Add creator as admin member
      await workspaceRef.collection('users').doc(_authController.userData.value.uid).set({
        'role': 'admin',
        'EnterDate': FieldValue.serverTimestamp(),
      });

      // Update user's workspace list
      await _firestore.collection('users').doc(_authController.userData.value.uid).update({
        'workspaces': FieldValue.arrayUnion([workspaceRef.id])
      });

      // Refresh workspaces list
      await fetchWorkspaces(_authController.userData.value.workspace);
      
      Get.snackbar('Success', 'Workspace created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create workspace: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch workspaces
  Future<void> fetchWorkspaces(List<dynamic> workspaceIds) async {
    try {
      isLoading(true);
      List<Workspace> fetchedWorkspaces = [];

      for (String workspaceId in workspaceIds) {
        final workspaceDoc = await _firestore.collection('workspaces').doc(workspaceId).get();
        
        if (workspaceDoc.exists) {
          List<Member> members = [];
          final membersSnapshot = await workspaceDoc.reference.collection('users').get();
          
          for (var memberDoc in membersSnapshot.docs) {
            members.add(Member.fromJson(memberDoc));
          }

          fetchedWorkspaces.add(
            Workspace(
              uid: workspaceId,
              name: workspaceDoc.data()?['name'] ?? '',
              members: members,
            ),
          );
        }
      }

      workspaces.assignAll(fetchedWorkspaces);
      if (fetchedWorkspaces.isNotEmpty) {
        selectedWorkSpace(fetchedWorkspaces[0]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch workspaces: $e');
    } finally {
      isLoading(false);
    }
  }

  // Add member to workspace
  Future<void> addMember(String email, String workspaceId) async {
    try {
      isLoadingUsers(true);
      
      // Find user by email
      final userQuery = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw 'User not found';
      }

      final userId = userQuery.docs.first.id;
      
      // Check if user is already a member
      final memberCheck = await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('users')
          .doc(userId)
          .get();

      if (memberCheck.exists) {
        throw 'User is already a member';
      }

      // Add user to workspace
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('users')
          .doc(userId)
          .set({
        'role': 'member',
        'EnterDate': FieldValue.serverTimestamp(),
      });

      // Update user's workspace list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'workspaces': FieldValue.arrayUnion([workspaceId])
      });

      // Refresh workspace data
      await fetchWorkspaces(_authController.userData.value.workspace);
      
      Get.snackbar('Success', 'Member added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member: $e');
    } finally {
      isLoadingUsers(false);
    }
  }

  // Remove member from workspace
  Future<void> removeMember(String userId, String workspaceId) async {
    try {
      isLoadingUsers(true);

      // Remove user from workspace
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('users')
          .doc(userId)
          .delete();

      // Update user's workspace list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'workspaces': FieldValue.arrayRemove([workspaceId])
      });

      // Refresh workspace data
      await fetchWorkspaces(_authController.userData.value.workspace);
      
      Get.snackbar('Success', 'Member removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove member: $e');
    } finally {
      isLoadingUsers(false);
    }
  }

  // Update member role
  Future<void> updateMemberRole(String userId, String workspaceId, String newRole) async {
    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('users')
          .doc(userId)
          .update({'role': newRole});

      await fetchWorkspaces(_authController.userData.value.workspace);
      Get.snackbar('Success', 'Member role updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update member role: $e');
    }
  }

  // Add this method to your WorkSpaceController class
  Future<void> getUsersData(List<Member> members) async {
    try {
      isLoadingUsers(true);
      List<UserModel> fetchedUsers = [];

      for (Member member in members) {
        final userDoc = await _firestore.collection('users').doc(member.uid).get();
        
        if (userDoc.exists) {
          fetchedUsers.add(UserModel.fromJson(userDoc));
        }
      }

      users.assignAll(fetchedUsers);
    } catch (e) {
      print('Error fetching users data: $e'); // Add debug print
      Get.snackbar('Error', 'Failed to fetch users data: $e');
    } finally {
      isLoadingUsers(false);
    }
  }
  // Update the selectedWorkspace setter
  setselectedWorkSpace(Workspace value) {
    selectedWorkSpace.value = value;
    fetchWorkspaceData();
  }

  // Add method to fetch all workspace data
  Future<void> fetchWorkspaceData() async {
    try {
      isLoading(true);
      // Fetch workspace members
      await getUsersData(selectedWorkSpace.value.members);
      
      // Fetch workspace channels
      final chatController = Get.find<ChatController>();
      await chatController.fetchChannels(selectedWorkSpace.value.uid);
      
      // Add other workspace data fetching here
      
    } catch (e) {
      print('Error fetching workspace data: $e');
      Get.snackbar('Error', 'Failed to fetch workspace data');
    } finally {
      isLoading(false);
    }
  }

  // Update your existing workspace selection method
  void selectWorkspace(Workspace workspace) {
    selectedWorkSpace.value = workspace;
    fetchWorkspaceData();
  }
}