// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/views/Auth/SignUpPage.dart';
import 'package:manager/views/HomePage.dart';
import 'package:manager/views/NavPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  RxBool isLoading = true.obs;
  Rx<UserModel> userData = UserModel(
          uid: "", firstName: "firstName",mail: "mail", lastName: "lastName", pfp: "pfp" , workspace: [])
      .obs;
  getIsLoading() => isLoading.value;
  getUserData() => userData;
  getUser() => _user.value;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); 

       final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /////////////////////////////////////////////////////
  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _initialScreen);
    ever(userData, (_) {
      if (userData.value.workspace.isNotEmpty) {
        WorkSpaceController.instance.fetchWorkspaces(userData.value.workspace);
      }
    });
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() =>  SignUpPage());
    } else {
      getCurrentUserData();
      Get.offAll(() =>   NavigationPage());
    }
  }

  void createUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => FirebaseFirestore.instance
                  .collection('users')
                  .doc(value.user!.uid)
                  .set({
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
                'mail' : email,
                'pfp':
                    "https://firebasestorage.googleapis.com/v0/b/chatapp-c641c.appspot.com/o/empty.jpg?alt=media&token=2f74e6a7-683e-416b-8e19-a0e2cadad40e"
                    ,
                    'workspaces' : [value.user!.uid]
              }));
         await _firestore.collection('workspaces').doc(instance.userData.value.uid).set({
          "name" :"personal" ,

        });

        await _firestore.collection('workspaces').doc(instance.userData.value.uid).collection('users').doc(instance.userData.value.uid).set({
            "EnterDate" : DateTime.now() , 
            "role" : "admin"
        });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar(
          "Mot de passe invalide",
          "",
          backgroundColor: Colors.white,
          colorText: const Color.fromARGB(255, 199, 13, 0),
          icon: const Icon(Icons.alarm),
          shouldIconPulse: true,
          barBlur: 20,
          isDismissible: true,
        );
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "email non valide",
          "",
          backgroundColor: Colors.white,
          colorText: const Color.fromARGB(255, 199, 13, 0),
          icon: const Icon(Icons.alarm),
          shouldIconPulse: true,
          barBlur: 20,
          isDismissible: true,
        );
      }
    }
  }

  ////////////////////////////////////////////////
 void loginUser(String email, String password) async {
  isLoading(true); // Set loading true before signing in
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    Get.snackbar(
      "Login Failed",
      e.code,
      backgroundColor: Colors.white,
      colorText: const Color.fromARGB(255, 199, 13, 0),
      icon: const Icon(Icons.error),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  } finally {
    isLoading(false); // Set loading false once sign in is complete
  }
}

  String getUserInitials(String userId) {
    if (userId == userData.value.uid) {
      return "${userData.value.firstName[0]}${userData.value.lastName[0]}";
    }
    
    // For other users, fetch from Firestore cache or return default
    try {
      final userDoc = _firestore.collection('users').doc(userId).get().then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          return "${data['firstName'][0]}${data['lastName'][0]}";
        }
        return "??";
      });
      return userDoc.toString();
    } catch (e) {
      return "??";
    }
  }

  String getUserName(String userId) {
    if (userId == userData.value.uid) {
      return "${userData.value.firstName} ${userData.value.lastName}";
    }
    
    // For other users, fetch from Firestore cache or return default
    try {
      final userDoc = _firestore.collection('users').doc(userId).get().then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          return "${data['firstName']} ${data['lastName']}";
        }
        return "Unknown User";
      });
      return userDoc.toString();
    } catch (e) {
      return "Unknown User";
    }
  }
  ////////////////////////////////////////
  void getCurrentUserData() async {
    isLoading(true);
    try {
      print(_user.value!.uid);

      // Use await to get the data from Firestore
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.value!.uid)
          .get();

      // Check if the document exists before converting data
      print(snapshot.data());
      if (snapshot.exists) {
        userData(UserModel.fromJson(snapshot));
        print(userData.value);
      } else {
        userData.value = UserModel.fromJson(snapshot);
        print('User data not found');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      // Handle the error accordingly
    } finally {
      isLoading(false);
    } 
    print("pexara0505000000000000000000000000000000000000000000000000000");
    print(userData.value);
    isLoading(false);
  }

/////////////////////////////
  void signOut() { _auth.signOut();
  _googleSignIn.signOut();
  WorkSpaceController.instance.workspaces.clear(); 
  userData.value = UserModel(uid: "uid", mail : " " ,firstName: "firstName", lastName: "lastName", pfp: "pfp", workspace: []);
  }












  ///////////////////////
  void resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    Get.snackbar(
      "Password Reset",
      "A password reset link has been sent to $email",
      backgroundColor: Colors.white,
      colorText: Colors.green,
      icon: const Icon(Icons.email),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.white,
      colorText: Colors.red,
      icon: const Icon(Icons.error),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  }
}

Future<void> updateUserProfile(String firstName, String lastName, String pfpUrl) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.value!.uid)
        .update({
      'firstName': firstName,
      'lastName': lastName,
      'pfp': pfpUrl,
    });

    // Update local userData
    userData.update((user) {
      user?.firstName = firstName;
      user?.lastName = lastName;
      user?.pfp = pfpUrl;
    });

    Get.snackbar(
      "Profile Updated",
      "Your profile has been successfully updated",
      backgroundColor: Colors.white,
      colorText: Colors.green,
      icon: const Icon(Icons.check),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  } catch (e) {
    Get.snackbar(
      "Update Failed",
      e.toString(),
      backgroundColor: Colors.white,
      colorText: Colors.red,
      icon: const Icon(Icons.error),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  }
}
void deleteUser() async {
  try {
    // Delete user from Firebase Authentication
    await _user.value!.delete();

    // Delete user data from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.value!.uid)
        .delete();

    Get.snackbar(
      "Account Deleted",
      "Your account has been successfully deleted",
      backgroundColor: Colors.white,
      colorText: Colors.green,
      icon: const Icon(Icons.delete),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );

    // Redirect to sign-up page
    Get.offAll(() => SignUpPage());
  } catch (e) {
    Get.snackbar(
      "Delete Failed",
      e.toString(),
      backgroundColor: Colors.white,
      colorText: Colors.red,
      icon: const Icon(Icons.error),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  }
}
void sendEmailVerification() async {
  try {
    if (!_user.value!.emailVerified) {
      await _user.value!.sendEmailVerification();
      Get.snackbar(
        "Verification Email Sent",
        "Please check your inbox to verify your email address.",
        backgroundColor: Colors.white,
        colorText: Colors.green,
        icon: const Icon(Icons.email),
        shouldIconPulse: true,
        barBlur: 20,
        isDismissible: true,
      );
    }
  } catch (e) {
    Get.snackbar(
      "Verification Failed",
      e.toString(),
      backgroundColor: Colors.white,
      colorText: Colors.red,
      icon: const Icon(Icons.error),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  }
}

bool isEmailVerified() {
  return _user.value!.emailVerified;
}


//

 Future<void> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Obtain the auth details from the Google sign-in request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo!.isNewUser) {
        // Store new user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': googleUser.displayName?.split(' ')[0] ?? "FirstName",
          'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? "LastName",
          'email': googleUser.email,
          'pfp': googleUser.photoUrl ?? "default-profile-picture-url"
        });
      }

      // Get user data from Firestore
      getCurrentUserData();

      // Navigate to HomePage
      Get.offAll(() => const HomePage());

      Get.snackbar(
        "Sign-In Successful",
        "Welcome, ${googleUser.displayName}",
        backgroundColor: Colors.white,
        colorText: Colors.green,
        icon: const Icon(Icons.check),
        shouldIconPulse: true,
        barBlur: 20,
        isDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        "Sign-In Failed",
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.red,
        icon: const Icon(Icons.error),
        shouldIconPulse: true,
        barBlur: 20,
        isDismissible: true,
      );
    }
  }

  /// Sign out (for both Google and Firebase Auth)
 

  Future<void> saveFCMToken(String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData.value.uid)
          .update({'fcmToken': token});
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      // ... existing sign in code ...

      // Get and save FCM token after successful sign in
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await saveFCMToken(fcmToken);
      }
    } catch (e) {
      // ... error handling ...
    }
  }

  // Add this property
  final RxMap<String, UserModel> userCache = <String, UserModel>{}.obs;

  // Replace getUserName with this
  Future<void> cacheUserData(String userId) async {
    if (userCache.containsKey(userId)) return;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      userCache[userId] = UserModel.fromJson(doc);
    }
  }

  String getUserNameSync(String userId) {
    return userCache[userId]?.firstName ?? 'Loading...';
  }

  String? getUserPhotoSync(String userId) {
    return userCache[userId]?.pfp;
  }
}
