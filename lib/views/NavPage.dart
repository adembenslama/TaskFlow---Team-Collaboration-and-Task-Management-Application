import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/BottomNavController.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/HomePage.dart';
import 'package:manager/views/chat/ChannelsPage.dart';
import 'package:manager/views/chat/ChatPage.dart';
import 'package:manager/views/profile/profilePage.dart';
import 'package:manager/views/schedule/CalendarView.dart';
import 'package:manager/views/tasks/TasksPage.dart';
import 'package:manager/views/feed/FeedPage.dart';

class NavigationPage extends StatelessWidget {
  final BottomNavController _navController = Get.put(BottomNavController());

  NavigationPage({super.key});

  final List<Widget> _pages = [
    const HomePage(),
    CalendarScreen(),
    const TasksPage(),
    ChannelsPage(),
    const FeedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      body: Obx(() => _pages[_navController.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: BottomNavigationBar(
              elevation: 0,
              selectedItemColor: royalBlue,
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey,
              currentIndex: _navController.currentIndex.value,
              type: BottomNavigationBarType.fixed,
              onTap: _navController.changeIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.calendar_1),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.task_square),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.message),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.activity),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.user),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
