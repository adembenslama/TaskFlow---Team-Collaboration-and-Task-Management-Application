import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/model/User.model.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/profile/EditProfilePage.dart';

class ProfilePage extends StatelessWidget {
  final AuthController _authController = AuthController.instance;

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile',
          style: boldTitle,
        ),
      ),
      body: Obx(() {
        if (_authController.getIsLoading()) {
          return const Center(child: CircularProgressIndicator());
        }

        UserModel user = _authController.getUserData().value;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.pfp),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.uid,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      CsutomProfileButton(
                        label: "Edit Profile",
                        onTap: () {Get.to(()=>const EditProfilePage());},
                        icon: const Icon(Iconsax.user_edit ),
                      ),
                      CsutomProfileButton(
                        label: "Notification Settings",
                        onTap: () {},
                         icon: const Icon(Iconsax.notification_bing),
                      ),
                      CsutomProfileButton(
                        label: "Contact Us",
                        onTap: () {},
                         icon: const Icon(Iconsax.people),
                      ), CsutomProfileButton(
                        label: "Help & FAQ's",
                        onTap: () {},
                         icon: const Icon(Icons.question_answer_outlined),
                      ),
               
                    
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: ElevatedButton.icon(
                      icon: const Icon(Iconsax.logout , color: Colors.red,),
                      onPressed: () {
                        AuthController().signOut();
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.transparent),
                          elevation: WidgetStatePropertyAll(0)),
                      label: Padding(
                        padding: const EdgeInsets.all(10.0),
                       
                        child: Row(
                          children: [
                            Text(
                              "Sign Out",
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              )),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.red,
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CsutomProfileButton extends StatelessWidget {
  final String label;
  final Icon icon ;
  final Function()? onTap;
  const CsutomProfileButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      iconAlignment: IconAlignment.start,
      onPressed: onTap,
      style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          iconColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(0)),

      label: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
          
            Text(
              label,
              style: boldText,
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded)
          ],
        ),
      ),
    );
  }
}
