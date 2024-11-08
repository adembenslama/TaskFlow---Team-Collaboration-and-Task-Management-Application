import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/chat_channel.dart';
import 'package:manager/theme.dart';

class ChatPage extends StatelessWidget {
  final ChatController _chatController = Get.put(ChatController());
  final WorkSpaceController _workspaceController = WorkSpaceController.instance;
  final TextEditingController _messageController = TextEditingController();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Channels sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                // Channels header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Channels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: const Icon(Iconsax.add),
                        onPressed: () => _showCreateChannelDialog(context),
                      ),
                    ],
                  ),
                ),
                // Channels list
                Expanded(
                  child: Obx(() {
                    if (_chatController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: _chatController.channels.length,
                      itemBuilder: (context, index) {
                        final channel = _chatController.channels[index];
                        return ListTile(
                          leading: Icon(
                            channel.type == 'channel' 
                                ? Iconsax.hashtag
                                : Iconsax.message,
                          ),
                          title: Text(channel.name),
                          selected: _chatController.selectedChannel.value?.id == channel.id,
                          onTap: () {
                            _chatController.selectedChannel.value = channel;
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          // Chat area
          Expanded(
            child: Obx(() {
              final selectedChannel = _chatController.selectedChannel.value;
              
              if (selectedChannel == null) {
                return const Center(
                  child: Text('Select a channel to start chatting'),
                );
              }

              return Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedChannel.type == 'channel' 
                              ? Iconsax.hashtag
                              : Iconsax.message,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedChannel.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Messages area
                  Expanded(
                    child: StreamBuilder(
                      stream: _chatController.getMessages(selectedChannel.id),
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
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ListTile(
                              title: Text(message.content),
                              subtitle: Text(message.timestamp.toString()),
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
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Iconsax.send1),
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
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCreateChannelDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Create Channel'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Channel Name',
            hintText: 'Enter channel name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _chatController.createChannel(
                  _workspaceController.selectedWorkSpace.value.uid,
                  nameController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}