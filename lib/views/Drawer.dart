import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/workspace.dart';
import 'package:manager/theme.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkSpaceController _workspaceController = WorkSpaceController.instance;
    final TextEditingController _workspaceNameController = TextEditingController();

    return Drawer(
      backgroundColor: backColor,
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: royalBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspaces',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Switch between your workspaces',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_workspaceController.getIsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _workspaceController.workspaces.length,
                itemBuilder: (context, index) {
                  final workspace = _workspaceController.workspaces[index];
                  return Obx(() => _WorkspaceListTile(
                    workspace: workspace,
                    isSelected: workspace.uid == 
                        _workspaceController.selectedWorkSpace.value.uid,
                    onTap: () {
                      _workspaceController.selectedWorkSpace.value = workspace;
                      Navigator.pop(context);
                    },
                  ));
                },
              );
            }),
          ),
          _CreateWorkspaceButton(
            controller: _workspaceNameController,
            workspaceController: _workspaceController,
          ),
        ],
      ),
    );
  }
}

// Extract WorkspaceListTile to a separate widget
class _WorkspaceListTile extends StatelessWidget {
  final Workspace workspace;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkspaceListTile({
    required this.workspace,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? royalBlue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? royalBlue : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Iconsax.building_3,
          color: isSelected ? royalBlue : Colors.grey,
        ),
        title: Text(
          workspace.name,
          style: TextStyle(
            color: isSelected ? royalBlue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${workspace.members.length} members',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CreateWorkspaceButton extends StatelessWidget {
  final TextEditingController controller;
  final WorkSpaceController workspaceController;

  const _CreateWorkspaceButton({
    required this.controller,
    required this.workspaceController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: ListTile(
        leading: const Icon(Iconsax.add_circle, color: royalBlue),
        title: const Text(
          'Create Workspace',
          style: TextStyle(
            color: royalBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Get.back();
          Get.dialog(
            AlertDialog(
              title: const Text('Create New Workspace'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Workspace Name',
                  hintText: 'Enter workspace name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      workspaceController.createWorkspace(
                        controller.text.trim(),
                      );
                      Get.back();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
