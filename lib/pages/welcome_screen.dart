// ignore_for_file: use_build_context_synchronously

import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/navigation/wrapper_nav.dart';
import 'package:ascend_fyp/pages/registration_screen.dart';
import 'package:ascend_fyp/sign-in/AuthService.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(20, 23, 26, 1),
    );

    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        const Color.fromRGBO(247, 243, 237, 1),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 125),
              Text(
                'Welcome back! \nGlad to see you again!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 50),
              TextField(
                style: Theme.of(context).textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(247, 243, 237, 1),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                style: Theme.of(context).textTheme.titleMedium,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(247, 243, 237, 1),
                      width: 2.5,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      !obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color.fromRGBO(247, 243, 237, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle login button press
                  },
                  style: buttonStyle,
                  child: Text(
                    'Login',
                    style: style,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              const Center(child: Text('Or Login with')),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: IconButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                                color: Color.fromRGBO(247, 243, 237, 1),
                                width: 3.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        String message = await AuthService().signInWithGoogle();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        if (message == "Login Successful") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WrapperNav(),
                            ),
                          );
                        }
                      },
                      icon: Image.asset(
                        'lib/assets/images/google_logo.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  SlidingNav(builder: (context) => const RegistrationScreen()),
                );
              },
              child: RichText(
                text: const TextSpan(
                  text: "Don't have an account yet? ",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Merriweather Sans',
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(247, 243, 237, 1),
                  ),
                  children: [
                    TextSpan(
                      text: "Create one today!",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Merriweather Sans',
                        color: Colors.blue,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
