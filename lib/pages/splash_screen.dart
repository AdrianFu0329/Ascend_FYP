import 'package:ascend_fyp/navigation/wrapper_nav.dart';
import 'package:ascend_fyp/pages/home_screen.dart';
import 'package:ascend_fyp/pages/nav_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WrapperNav()),
      );
    });

    return Scaffold(
      body: Center(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/logo.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
