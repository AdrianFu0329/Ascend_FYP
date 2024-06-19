import 'package:ascend_fyp/database/firebase_options.dart';
import 'package:ascend_fyp/general%20pages/splash_screen.dart';
import 'package:ascend_fyp/navigation/screens/nav_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    // ignore: avoid_print
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageNavigation(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageNavigation(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground message if needed
      if (message.notification != null) {
        // Show in-app notification or snackbar if needed
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      final Map<String, dynamic> data = message.data;

      // Extract the type from the data payload
      final String? type = data['data']['type'];

      if (type == 'chat') {
        Navigator.pushNamed(context, '/messages');
      } else {
        Navigator.pushNamed(context, '/start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/start': (context) => const NavScreen(),
        '/messages': (context) => const NavScreen(index: 1),
      },
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
          titleMedium: TextStyle(
            fontSize: 12,
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
      ),
    );
  }
}
