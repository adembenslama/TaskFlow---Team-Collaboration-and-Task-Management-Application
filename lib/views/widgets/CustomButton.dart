import 'package:flutter/material.dart';
import 'package:manager/theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  const CustomButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width*0.6,
             
        child: ElevatedButton(
          
            onPressed: onTap,
            child: Text(
              label,
              style: buttonText,
            ) , 
          
            
            ),
      ),
    );
  }
}
