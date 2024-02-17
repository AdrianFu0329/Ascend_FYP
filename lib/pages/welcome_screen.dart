import 'package:ascend_fyp/navigation/wrapper_nav.dart';
import 'package:ascend_fyp/sign-in/AuthService.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'lib/assets/images/welcome_img1.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Expanded(
                  child: Column(
                    children: [
                      // Button for Google account login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Call signInWithGoogle when the button is pressed
                            String message =
                                await AuthService().signInWithGoogle();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            // Navigate to the HomeScreen after successful sign-in
                            if (message == "Login Successful") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WrapperNav(),
                                ),
                              );
                            }
                          },
                          style: buttonStyle,
                          icon: Image.asset(
                            'lib/assets/images/google_logo.png',
                            width: 30,
                            height: 30,
                          ),
                          label: Text(
                            'Login with Google',
                            style: style,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Button for email/password login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle email/password login
                          },
                          style: buttonStyle,
                          icon: const Icon(
                            Icons.key,
                            size: 30,
                            color: Color.fromRGBO(20, 23, 26, 1),
                          ),
                          label: Text(
                            'Login with Password',
                            style: style,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
