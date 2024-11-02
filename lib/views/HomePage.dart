import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/Drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    final AuthController _authController = AuthController.instance;
    final WorkSpaceController _workspace = WorkSpaceController.instance;

  
    @override
    Widget build(BuildContext context) {
      return  Obx(
        (){
        while (_authController.getIsLoading()||_workspace.getIsLoading()) {
          
          return const Center(child: CircularProgressIndicator());
        }
     


        UserModel user = _authController.getUserData().value;
          return  Scaffold(
          backgroundColor: backColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
           
             
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_workspace.workspaces[0].name, style: lightGray16),
                    Text(
                      "${user.firstName.capitalize} ${user.lastName.capitalize}",
                      style: lightGray10),
                ],

              ),
              const Spacer() ,
              IconButton(onPressed: (){}, icon: const Icon(Iconsax.notification , size: 30, color: Colors.black54,)), 
              const SizedBox(width: 5,) ,
            ],
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Iconsax.arrow_square_left , color: Colors.black,),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer on icon tap
              },
            ),
          ),
        ),
         drawer: const MyDrawer(),
      body:const Column(
        children: [
          Text("edeede")
        ],
      ),
    );
      }
    );
  }
}