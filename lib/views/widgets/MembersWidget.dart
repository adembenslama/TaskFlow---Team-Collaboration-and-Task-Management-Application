import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/model/workspace.dart';
import 'package:manager/theme.dart';

class MembersWidget extends StatefulWidget {
  final List<UserModel> users;
  final bool stacked;
  final bool canAdd;

  const MembersWidget({
    super.key,
    required this.users,
    required this.stacked,
    required this.canAdd,
  });

  @override
  State<MembersWidget> createState() => _MembersWidgetState();
}

class _MembersWidgetState extends State<MembersWidget> {
  final WorkSpaceController _workspace = Get.find();
  final TextEditingController _searchController = TextEditingController();
  RxList<UserModel> filteredUsers = <UserModel>[].obs;

  @override
  void initState() {
    super.initState();
    if (_workspace.selectedWorkSpace.value.members.isNotEmpty) {
      _workspace.getUsersData(_workspace.selectedWorkSpace.value.members);
    }
    filteredUsers.assignAll(widget.users);
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      filteredUsers.assignAll(widget.users);
    } else {
      filteredUsers.assignAll(widget.users.where((user) =>
          '${user.firstName} ${user.lastName}'.toLowerCase().contains(query.toLowerCase()) ||
          user.mail.toLowerCase().contains(query.toLowerCase())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_workspace.getIsLoadingUser) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final displayCount = widget.users.length > 5 ? 5 : widget.users.length;
      
      return GestureDetector(
        onTap: () => _showAllMembers(context),
        child: Container(
          height: 50,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            children: [
              for (int i = 0; i < displayCount; i++)
                if (i != 4 || displayCount == widget.users.length)
                  Positioned(
                    left: widget.stacked ? i * 40.0 : i * 55.0,
                    child: _buildMemberAvatar(widget.users[i]),
                  ),
              if (widget.users.length > 5)
                Positioned(
                  left: widget.stacked ? (displayCount - 1) * 40.0 : (displayCount - 1) * 55.0,
                  child: _buildMoreAvatar(widget.users.length - 4),
                ),
              if (widget.canAdd)
                Positioned(
                  left: widget.stacked ? displayCount * 40.0 : displayCount * 55.0,
                  child: _buildAddButton(),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMemberAvatar(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(user.pfp),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showMemberDetails(user),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreAvatar(int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: royalBlue,
        child: IconButton(
          icon: const Icon(Iconsax.add, color: Colors.white),
          onPressed: () => showAddMemberDialog(context),
        ),
      ),
    );
  }

  void _showMemberDetails(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Member Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.pfp),
            ),
            const SizedBox(height: 16),
            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(user.mail),
            const SizedBox(height: 16),
            Text('Role: ${_getMemberRole(user.uid)}'),
          ],
        ),
        actions: [
          if (_isCurrentUserAdmin())
            TextButton(
              onPressed: () => _showRemoveMemberDialog(user),
              child: const Text('Remove Member', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getMemberRole(String userId) {
    final member = _workspace.selectedWorkSpace.value.members
        .firstWhere((m) => m.uid == userId, orElse: () => Member(uid: '', role: 'member', inTime: DateTime.now()));
    return member.role.capitalize ?? 'Member';
  }

  bool _isCurrentUserAdmin() {
    final currentUserId = _workspace.selectedWorkSpace.value.members
        .firstWhere((m) => m.role == 'admin', orElse: () => Member(uid: '', role: '', inTime: DateTime.now()))
        .uid;
    return currentUserId.isNotEmpty;
  }

  void _showRemoveMemberDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${user.firstName} ${user.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _workspace.removeMember(
                user.uid,
                _workspace.selectedWorkSpace.value.uid,
              );
              Get.back();
              Get.back();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAllMembers(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('All Members'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: Icon(Iconsax.search_normal),
                ),
                onChanged: _filterUsers,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.pfp),
                      ),
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: Text(user.mail),
                      trailing: Text(_getMemberRole(user.uid)),
                      onTap: () => _showMemberDetails(user),
                    );
                  },
                )),
              ),
            ],
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

  void showAddMemberDialog(BuildContext context) {
    final selectedUsers = <String>{}.obs;
    final searchController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Members'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: Icon(Iconsax.search_normal),
                ),
                onChanged: _filterUsers,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = selectedUsers.contains(user.uid);
                      final isMember = _workspace.selectedWorkSpace.value.members
                          .any((member) => member.uid == user.uid);

                      if (isMember) return const SizedBox.shrink();

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.pfp),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.mail),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            if (isSelected) {
                              selectedUsers.remove(user.uid);
                            } else {
                              selectedUsers.add(user.uid);
                            }
                          },
                        ),
                        onTap: () {
                          if (isSelected) {
                            selectedUsers.remove(user.uid);
                          } else {
                            selectedUsers.add(user.uid);
                          }
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
          ElevatedButton(
            onPressed: () {
              for (String userId in selectedUsers) {
                _workspace.addMember(
                  userId,
                  _workspace.selectedWorkSpace.value.uid,
                );
              }
              Get.back();
            },
            child: const Text('Add Selected'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}