import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/theme.dart';

class OperationTile extends StatelessWidget {
   final String label;
  final Function()? onTap;
  final IconData  icon ;
  const OperationTile({super.key , required this.icon , required  this.label , this.onTap});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:  Icon(
                icon ,
                color: royalBlue,
                size: 27,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
