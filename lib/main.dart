import 'package:ascend_fyp/firebase_options.dart';
import 'package:ascend_fyp/pages/home_screen.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:ascend_fyp/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
            bodySmall: TextStyle(
              fontSize: 11,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.normal,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            titleSmall: TextStyle(
              fontSize: 13,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.normal,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
          ),
          scaffoldBackgroundColor: const Color.fromRGBO(32, 47, 57, 1),
          cardColor: const Color.fromRGBO(32, 47, 57, 1),
          buttonTheme: const ButtonThemeData(
              buttonColor: Color.fromRGBO(247, 243, 237, 1))),
      routes: {
        '/homeScreen': (context) => const HomeScreen(),
        '/mediaPostScreen': (context) => const MediaPostScreen(),
      },
    );
  }
}
