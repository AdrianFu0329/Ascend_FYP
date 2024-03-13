import 'package:ascend_fyp/database/firebase_options.dart';
import 'package:ascend_fyp/pages/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
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
            titleLarge: TextStyle(
              fontSize: 24,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.normal,
              color: Color.fromRGBO(247, 243, 237, 1),
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
            labelSmall: TextStyle(
              fontSize: 9,
              fontFamily: 'Merriweather Sans',
              fontWeight: FontWeight.normal,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
          ),
          scaffoldBackgroundColor: const Color.fromRGBO(20, 23, 26, 1),
          cardColor: const Color.fromRGBO(32, 47, 57, 1),
        ));
  }
}
