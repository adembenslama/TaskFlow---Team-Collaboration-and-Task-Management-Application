import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}


class _LandingpageState extends State<Landingpage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _startAlignmentAnimation;
  late Animation<Alignment> _endAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds:5),
    )..repeat(reverse: true); // Continuously loops the animation

    // Animating the start and end alignment of the gradient
    _startAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    ).animate(_controller);

    _endAlignmentAnimation = AlignmentTween(
      begin: Alignment.bottomRight,
      end: Alignment.bottomLeft,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color.fromARGB(255, 255, 12, 12), // Start color
                  Color.fromARGB(255, 252, 98, 98),   // End color
                ],
                begin: _startAlignmentAnimation.value,
                end: _endAlignmentAnimation.value,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.2,
                    MediaQuery.of(context).size.width * 0.4,
                    MediaQuery.of(context).size.width * 0.2,
                    0,
                  ),
                  child: Image.asset(
                    "assets/LOGO.png",
                  ),
                ),
                const Spacer(),
                Lottie.asset("assets/landing.json")
              ],
            ),
          );
        },
      ),
    );
  }
}
