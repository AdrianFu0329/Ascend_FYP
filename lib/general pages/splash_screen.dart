import 'package:ascend_fyp/location/service/Geolocation.dart';
import 'package:ascend_fyp/navigation/wrapper_nav.dart';
import 'package:ascend_fyp/notifications/service/local_notification_service.dart';
import 'package:ascend_fyp/welcome/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WrapperNav()),
          );
        }
        GeoLocation geoLocation = GeoLocation();
        await geoLocation.getLocation();
        await NotificationService.init();
        tz.initializeTimeZones();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
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
                height: 250,
                width: 250,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
