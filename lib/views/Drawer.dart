import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/theme.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkSpaceController _workspaceController = WorkSpaceController.instance;

    return Drawer(
      backgroundColor: backColor,
      child: Column(
        children: <Widget>[
          
          Expanded(
            child: Obx(() {
              if (_workspaceController.getIsLoading()) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(

                itemCount: _workspaceController.workspaces.length,
                itemBuilder: (context, index) {
                  final workspace = _workspaceController.workspaces[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 15 ,  right: 15 , top: 10 ),

                  

                    decoration: BoxDecoration(
                    color: Colors.white, 
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.workspaces_outline),
                      title: Text(workspace.name ),
                      onTap: () {
                        // Navigate to the workspace details or switch to the workspace
                        Navigator.pop(context); // Close the drawer after selecting
                      },
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Workspace'),
              onTap: () {
                // Handle adding a new workspace here
                Navigator.pop(context); // Close the drawer
              },
            ),
          ),
        ],
      ),
    );
  }
}
