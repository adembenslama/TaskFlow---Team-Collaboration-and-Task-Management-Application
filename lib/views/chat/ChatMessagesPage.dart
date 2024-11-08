import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatMessagesPage extends StatelessWidget {
  final ChatController _chatController = Get.find();
  final AuthController _authController = AuthController.instance;
  final TextEditingController _messageController = TextEditingController();

  ChatMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final channel = _chatController.selectedChannel.value!;

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Icon(
              channel.type == 'channel' ? Iconsax.hashtag : Iconsax.message,
              color: royalBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              channel.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle, color: Colors.black),
            onPressed: () {
              // Show channel info/members
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: StreamBuilder(
              stream: _chatController.getMessages(channel.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = 
                        message.senderId == _authController.userData.value.uid;
                    final messageTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);

                    return Align(
                      alignment: isMyMessage 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMyMessage ? royalBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMyMessage ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(messageTime),
                              style: TextStyle(
                                color: isMyMessage 
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.attach_circle, color: Colors.grey),
                  onPressed: () {
                    // Handle attachments
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.send1, color: royalBlue),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _chatController.sendMessage(
                        _messageController.text.trim(),
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 