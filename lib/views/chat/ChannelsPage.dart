import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/ChatController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/model/chat_channel.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/chat/ChatMessagesPage.dart';

class ChannelsPage extends GetView<ChatController> {
  final WorkSpaceController _workspaceController = WorkSpaceController.instance;
  final RxBool showChannels = true.obs; // Track which view to show
  
  ChannelsPage({super.key}) {
    // Fetch channels when page is created
    Get.find<ChatController>().fetchChannels(
      _workspaceController.selectedWorkSpace.value.uid
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Obx(() => TextButton(
              onPressed: () => showChannels.value = true,
              child: Text(
                'Channels',
                style: TextStyle(
                  color: showChannels.value ? royalBlue : Colors.grey,
                  fontWeight: showChannels.value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )),
            const SizedBox(width: 16),
            Obx(() => TextButton(
              onPressed: () => showChannels.value = false,
              child: Text(
                'Direct Messages',
                style: TextStyle(
                  color: !showChannels.value ? royalBlue : Colors.grey,
                  fontWeight: !showChannels.value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )),
          ],
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              showChannels.value ? Iconsax.add_circle : Iconsax.message_add,
              color: royalBlue
            ),
            onPressed: () => showChannels.value 
                ? _showCreateChannelDialog(context)
                : _showNewMessageDialog(context),
          )),
        ],
      ),
      body: Obx(() {
        if (_workspaceController.isLoading.value || controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = showChannels.value 
            ? controller.channels.where((c) => c.type == 'channel').toList()
            : controller.channels.where((c) => c.type == 'direct').toList();

        if (items.isEmpty) {
          return Center(
            child: Text(
              showChannels.value 
                  ? 'No channels yet. Create one to get started!'
                  : 'No direct messages yet. Start a conversation!',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final channel = items[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: Icon(
                  channel.type == 'channel' ? Iconsax.hashtag : Iconsax.message,
                  color: royalBlue,
                ),
                title: Text(
                  channel.type == 'channel'
                      ? channel.name
                      : _getDMName(channel), // Get other user's name for DMs
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  channel.type == 'channel' 
                      ? '${channel.members.length} members'
                      : 'Direct Message',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  controller.selectedChannel.value = channel;
                  Get.to(() => ChatMessagesPage());
                },
              ),
            );
          },
        );
      }),
    );
  }

  String _getDMName(ChatChannel channel) {
    // Get the other user's name in the DM
    final otherUserId = channel.members.firstWhere(
      (id) => id != _workspaceController.selectedWorkSpace.value.uid
    );
    final otherUser = _workspaceController.users.firstWhere(
      (user) => user.uid == otherUserId,
      orElse: () => UserModel(
        uid: otherUserId,
        firstName: 'Unknown',
        lastName: 'User',
        mail: '',
        pfp: '',
        workspace: []
      ),
    );
    return '${otherUser.firstName} ${otherUser.lastName}';
  }

  void _showNewMessageDialog(BuildContext context) {
    final selectedUsers = <String>{}.obs;
    
    Get.dialog(
      AlertDialog(
        title: const Text('New Message'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text('Select a user to message:'),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final workspaceMembers = _workspaceController
                      .selectedWorkSpace.value.members;
                  
                  return ListView.builder(
                    itemCount: workspaceMembers.length,
                    itemBuilder: (context, index) {
                      final member = workspaceMembers[index];
                      final user = _workspaceController.users.firstWhere(
                        (u) => u.uid == member.uid,
                        orElse: () => UserModel(
                          uid: member.uid,
                          firstName: 'Unknown',
                          lastName: 'User',
                          mail: '',
                          pfp: '',
                          workspace: []
                        ),
                      );

                      // Don't show current user
                      if (user.uid == _workspaceController.selectedWorkSpace.value.uid) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.pfp),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.mail),
                        onTap: () {
                          // Create or open DM channel
                          controller.createOrOpenDirectMessage(
                            _workspaceController.selectedWorkSpace.value.uid,
                            user.uid,
                            '${user.firstName} ${user.lastName}'
                          );
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
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
                controller.createChannel(
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