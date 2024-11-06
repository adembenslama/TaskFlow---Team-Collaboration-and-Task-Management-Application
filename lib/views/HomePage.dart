import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/Drawer.dart';
import 'package:manager/views/widgets/MembersWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthController _authController = AuthController.instance;
  final WorkSpaceController _workspace = WorkSpaceController.instance;
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    _workspace.selectedWorkSpace.value.name, 
                    style: lightGray16
                  )),
                  Text(
                    "${_authController.userData.value.firstName.capitalize} ${_authController.userData.value.lastName.capitalize}",
                    style: lightGray10
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {}, 
                icon: const Icon(Iconsax.notification, 
                     size: 30, 
                     color: Colors.black54)
              ),
              const SizedBox(width: 5),
            ],
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Iconsax.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Workspace Members",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              MembersWidget(
                users: _workspace.getUsers,
                stacked: true,
                canAdd: true,
              ),
              const SizedBox(height: 24),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    icon: Iconsax.calendar_1,
                    title: "Schedule",
                    onTap: () => Get.toNamed('/calendar'),
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.message,
                    title: "Chat",
                    onTap: () => Get.toNamed('/chat'),
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.task_square,
                    title: "Tasks",
                    onTap: () => Get.toNamed('/tasks'),
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.document,
                    title: "Files",
                    onTap: () => Get.toNamed('/files'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: royalBlue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
