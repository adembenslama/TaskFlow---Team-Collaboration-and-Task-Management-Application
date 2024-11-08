import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/chat_message.dart';
import 'package:manager/model/chat_channel.dart';
import 'package:manager/views/chat/ChatMessagesPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  RxList<ChatChannel> channels = <ChatChannel>[].obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  Rx<ChatChannel?> selectedChannel = Rx<ChatChannel?>(null);
  RxBool isLoading = false.obs;

  // Fetch channels for workspace
  Future<void> fetchChannels(String workspaceId) async {
    try {
      isLoading(true);
      
      // Fetch public channels
      final channelsSnapshot = await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('channels')
          .get();

      final List<ChatChannel> allChannels = channelsSnapshot.docs
          .map((doc) => ChatChannel.fromJson(doc))
          .toList();

      // Add default 'main' channel if it doesn't exist
      if (allChannels.isEmpty) {
        await createChannel(workspaceId, 'main');
      }

      channels.assignAll(allChannels);
    } catch (e) {
      print('Error fetching channels: $e'); // Debug print
      Get.snackbar('Error', 'Failed to fetch channels: $e');
    } finally {
      isLoading(false);
    }
  }

  // Create new channel
  Future<void> createChannel(String workspaceId, String name, {bool isDirectMessage = false, List<String>? members}) async {
    try {
      final channelRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('channels')
          .doc();

      final ChatChannel newChannel = ChatChannel(
        id: channelRef.id,
        name: name,
        workspaceId: workspaceId,
        type: isDirectMessage ? 'direct' : 'channel',
        members: isDirectMessage 
            ? (members ?? []) 
            : [_authController.userData.value.uid],
        createdAt: DateTime.now(),
        createdBy: _authController.userData.value.uid,
      );

      await channelRef.set(newChannel.toJson());
      await fetchChannels(workspaceId);
      
      Get.snackbar('Success', 'Channel created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create channel: $e');
    }
  }

  // Get messages for a channel
  Stream<List<ChatMessage>> getMessages(String channelId) {
    return _firestore
        .collection('workspaces')
        .doc(selectedChannel.value?.workspaceId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc))
              .toList();
        });
  }

  // Send message to channel
  Future<void> sendMessage(String content, {String? replyTo}) async {
    try {
      if (selectedChannel.value == null) return;

      final messageRef = _firestore
          .collection('workspaces')
          .doc(selectedChannel.value?.workspaceId)
          .collection('channels')
          .doc(selectedChannel.value?.id)
          .collection('messages')
          .doc();

      final message = ChatMessage(
        id: messageRef.id,
        content: content,
        senderId: _authController.userData.value.uid,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        replyTo: replyTo,
        type: 'text',
      );

      await messageRef.set(message.toJson());

      // Send notifications to channel members
      await _sendNotificationToMembers(content);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  Future<void> _sendNotificationToMembers(String messageContent) async {
    try {
      final channel = selectedChannel.value!;
      final currentUser = _authController.userData.value;

      // Get FCM tokens of other channel members
      final memberDocs = await _firestore
          .collection('users')
          .where('uid', whereIn: channel.members)
          .where('uid', isNotEqualTo: currentUser.uid)
          .get();

      final tokens = memberDocs.docs
          .map((doc) => doc.data()['fcmToken'] as String?)
          .where((token) => token != null)
          .toList();

      if (tokens.isEmpty) return;

      // Send notification using FCM REST API
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY', // Get this from Firebase Console
        },
        body: jsonEncode({
          'registration_ids': tokens,
          'notification': {
            'title': '${currentUser.firstName} in ${channel.name}',
            'body': messageContent,
          },
          'data': {
            'type': 'chat',
            'channelId': channel.id,
            'workspaceId': channel.workspaceId,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw 'Failed to send notifications';
      }
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  Future<void> createOrOpenDirectMessage(String workspaceId, String otherUserId, String otherUserName) async {
    try {
      isLoading(true);
      
      // Check if DM channel already exists
      final existingDM = channels.firstWhereOrNull((channel) => 
        channel.type == 'direct' && 
        channel.members.contains(otherUserId) &&
        channel.members.contains(_authController.userData.value.uid)
      );

      if (existingDM != null) {
        // Open existing DM
        selectedChannel.value = existingDM;
        Get.to(() => ChatMessagesPage());
        return;
      }

      // Create new DM channel
      final channelRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('channels')
          .doc();

      final ChatChannel newChannel = ChatChannel(
        id: channelRef.id,
        name: otherUserName, // Use other user's name as channel name
        workspaceId: workspaceId,
        type: 'direct',
        members: [_authController.userData.value.uid, otherUserId],
        createdAt: DateTime.now(),
        createdBy: _authController.userData.value.uid,
      );

      await channelRef.set(newChannel.toJson());
      await fetchChannels(workspaceId);
      
      // Open new DM
      selectedChannel.value = channels.firstWhere((c) => c.id == channelRef.id);
      Get.to(() => ChatMessagesPage());
    } catch (e) {
      Get.snackbar('Error', 'Failed to create conversation: $e');
    } finally {
      isLoading(false);
    }
  }
}