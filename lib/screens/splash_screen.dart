import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:public_assist_hub/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define Zoom-In Animation
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    // Start Animation
    _controller.forward();

    // Navigate to Home Screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth fade transition
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          LottieBuilder.asset('assets/Public Service.json',),
          // Zoom-In Text Animation
          FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Text(
                "Public Service Hub",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
