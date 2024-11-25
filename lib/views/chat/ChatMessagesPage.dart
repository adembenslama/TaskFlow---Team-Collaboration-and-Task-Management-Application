import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/chat_message.dart';
import 'package:manager/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ChatMessagesPage extends StatelessWidget {
  final ChatController _chatController = Get.find();
  final AuthController _authController = AuthController.instance;
  final TextEditingController _messageController = TextEditingController();

  ChatMessagesPage({super.key});

  Widget _buildMessageStatus(ChatMessage message, bool isMyMessage) {
    if (!isMyMessage) return const SizedBox.shrink();

    IconData icon;
    Color color = Colors.grey;

    switch (message.status) {
      case 'sending':
        icon = Icons.access_time;
        break;
      case 'sent':
        icon = Icons.check;
        break;
      case 'delivered':
        icon = Icons.done_all;
        break;
      case 'seen':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      default:
        icon = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isMyMessage) {
    return GestureDetector(
      onLongPress: () => _showReactionPicker(context, message),
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
          maxWidth: MediaQuery.of(context).size.width * 0.50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == 'file') ...[
              _buildFilePreview(message, isMyMessage),
              if (!message.content.startsWith('http')) // Still uploading
                LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMyMessage ? Colors.white : royalBlue,
                  ),
                ),
            ] else 
              // Text message
              Text(
                message.content,
                style: TextStyle(
                  color: isMyMessage ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
          
            
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                          style: TextStyle(
                            color: isMyMessage 
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        _buildMessageStatus(message, isMyMessage),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _buildReactions(message.reactions, isMyMessage),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(ChatMessage message, bool isMyMessage) {
    final fileType = _chatController.getFileType(message.content);
    
    Widget preview;
    switch (fileType) {
      case 'image':
        preview = message.content.startsWith('http')
            ? Image.network(
                message.content,
                height: 150,
                width: 200,
                fit: BoxFit.cover,
              )
            : const SizedBox(height: 150, width: 200);
        break;
      case 'video':
        preview = Container(
          height: 150,
          width: 200,
          color: Colors.black,
          child: const Icon(Icons.play_circle, color: Colors.white, size: 50),
        );
        break;
      default:
        preview = Row(
          children: [
            Icon(Iconsax.document, color: isMyMessage ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.content.split('/').last,
                style: TextStyle(
                  color: isMyMessage ? Colors.white : Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
    }

    return GestureDetector(
      onTap: () => _chatController.handleFileClick(
        message.content,
        message.content.split('/').last,
      ),
      child: preview,
    );
  }

  void _showReactionPicker(BuildContext context, ChatMessage message) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        content: Wrap(
          spacing: 8,
          children: emojis.map((emoji) => 
            InkWell(
              onTap: () {
                _chatController.toggleReaction(message.id, emoji);
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildReactions(Map<String, List<String>> reactions, bool isMyMessage) {
    return Wrap(
      spacing: 4,
      children: reactions.entries.map((entry) {
        return InkWell(
          onTap: () => _showReactionUsers(entry.key, entry.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key),
                const SizedBox(width: 4),
                Text('${entry.value.length}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showReactionUsers(String emoji, List<String> userIds) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(emoji),
            const SizedBox(width: 8),
            const Text('Reactions'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<String>>(
            future: Future.wait(
              userIds.map((id) => _chatController.getUserName(id))
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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

                // Mark messages as seen
                for (var message in messages) {
                  if (message.senderId != _authController.userData.value.uid &&
                      !message.seenBy.contains(_authController.userData.value.uid)) {
                    _chatController.markMessageAsSeen(message.id);
                  }
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = 
                        message.senderId == _authController.userData.value.uid;

                    return _buildMessageBubble(context, message, isMyMessage);
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
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      _chatController.sendFileMessage(file);
                    }
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