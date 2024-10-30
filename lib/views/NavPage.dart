import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/BottomNavController.dart';
import 'package:manager/views/Drawer.dart';
import 'package:manager/theme.dart';



class NavigationPage extends StatelessWidget {
  // Create an instance of the BottomNavController
  final BottomNavController _navController = Get.put(BottomNavController());

  final List<Widget> _pages = [
    const HomeScreen(),
    // ignore: prefer_const_constructors
    SearchScreen(),
    const ProfileScreen(),
    const ProfileScreen(),
  ];

   NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Welcome' ,style :  lightGray20),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer on icon tap
            },
          ),
        ),
      ),
       drawer: const MyDrawer(), 
      body: Obx(() => _pages[_navController.currentIndex.value]), // Reactive update
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _navController.currentIndex.value,
          onTap: (index) {
            _navController.changeIndex(index); // Update the index using GetX
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),  
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen', style: TextStyle(fontSize: 24)),
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
      child: Text('Profile Screen', style:  TextStyle(fontSize: 24)),
    );
  }
}
