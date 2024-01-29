import 'package:ascend_fyp/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // ignore: avoid_print
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 36,
            fontFamily: 'Merriweather Sans',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 47, 57, 1),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontFamily: 'Merriweather Sans',
            fontWeight: FontWeight.normal,
            color: Color.fromRGBO(32, 47, 57, 1),
          ),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(247, 243, 237, 1),
      ),
    );
  }
}
