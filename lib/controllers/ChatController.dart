import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/chat_message.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isLoading = false.obs;

  // Stream of messages for a specific workspace
  Stream<List<ChatMessage>> getMessages(String workspaceId) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc))
              .toList();
        });
  }

  // Send a message
  Future<void> sendMessage(String workspaceId, String content, {String? replyTo}) async {
    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('messages')
          .add({
        'content': content,
        'senderId': _authController.userData.value.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'replyTo': replyTo,
        'type': 'text',
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String workspaceId, String messageId) async {
    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message: $e');
    }
  }

  // Edit a message
  Future<void> editMessage(String workspaceId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'edited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to edit message: $e');
    }
  }
}