import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/BottomNavController.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/HomePage.dart';
import 'package:manager/views/profile/profilePage.dart';
import 'package:manager/views/schedule/CalendarView.dart';
import 'package:manager/views/widgets/CustomButton.dart';
import 'package:manager/views/widgets/taskWidgetCopy.dart';

class NavigationPage extends StatelessWidget {
  // Create an instance of the BottomNavController
  final BottomNavController _navController = Get.put(BottomNavController());

  final List<Widget> _pages = [
    const HomePage(),
    // ignore: prefer_const_constructors
    CalendarScreen(),
    const ProfileScreen(),
    const ProfileScreen(),
    const ProfileScreen(),
    ProfilePage(),
  ];

  NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      body: Obx(
          () => _pages[_navController.currentIndex.value]), // Reactive update
      bottomNavigationBar: Obx(
        () => ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          child: SizedBox(
            height: 80,
            child: BottomNavigationBar(
              elevation: 0,
              selectedItemColor: royalBlue,
              backgroundColor: Colors.black,
              unselectedItemColor: Colors.grey,
              currentIndex: _navController.currentIndex.value,
              onTap: (index) {
                _navController
                    .changeIndex(index); // Update the index using GetX
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Iconsax.home ,),
                    label: 'Home',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Iconsax.calendar_1),
                    label: 'Calendar',
                    backgroundColor: Colors.white),
                       BottomNavigationBarItem(
                    icon: Icon(Iconsax.menu_board),
                    label: 'Boards',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Iconsax.message),
                    label: 'Messages',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Iconsax.archive),
                    label: 'Feed',
                    backgroundColor: Colors.white),
                      BottomNavigationBarItem(
                    icon: Icon(Iconsax.user),
                    label: 'Profile',
                    backgroundColor: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CustomButton(label: "hi", onTap: () {}),
          Row(
            children: [
              OperationTile(
                icon: Icons.search,
                label: "Search",
                onTap: () {},
              ),
              OperationTile(
                icon: Icons.send,
                label: "Send",
                onTap: () {},
              ),
              OperationTile(
                icon: Icons.share,
                label: "Share",
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
    );
  }
}
