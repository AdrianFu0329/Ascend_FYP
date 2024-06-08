// ignore_for_file: use_build_context_synchronously

import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/navigation/wrapper_nav.dart';
import 'package:ascend_fyp/general%20pages/forgot_pwd_screen.dart';
import 'package:ascend_fyp/general%20pages/registration_screen.dart';
import 'package:ascend_fyp/auth_service/AuthService.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoggingIn = false;

  void _showMessage(String message, bool confirm,
      {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm) {
                  if (onYesPressed != null) {
                    onYesPressed();
                  }
                } else {
                  if (onOKPressed != null) {
                    onOKPressed();
                  }
                }
              },
              child: Text(
                confirm ? 'Yes' : 'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            confirm
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Future<void> signInWithPwd() async {
    setState(() {
      _isLoggingIn = true;
    });
    String pwdLoginMsg = await AuthService().signInWithPwd(
      emailController.text,
      passwordController.text,
    );
    if (pwdLoginMsg == "Login Successful") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pwdLoginMsg)));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WrapperNav(),
        ),
      );
    } else if (pwdLoginMsg ==
        "Email not verified. Please check your email for verification.") {
      _showMessage(
        "$pwdLoginMsg\n\n Would you like us to send you another verification email?",
        true,
        onYesPressed: () async {
          String resendMsg = await AuthService().resendVerificationEmail();
          _showMessage(resendMsg, false);
        },
      );

      setState(() {
        _isLoggingIn = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect email or password!\nPlease try again!"),
        ),
      );
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<void> googleSignIn() async {
    setState(() {
      _isLoggingIn = true;
    });
    String googleLoginMsg = await AuthService().signInWithGoogle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(googleLoginMsg)),
    );
    if (googleLoginMsg == "Login Successful") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(googleLoginMsg)));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WrapperNav(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Error!\nPlease try again..."),
        ),
      );
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(20, 23, 26, 1),
    );

    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        const Color.fromRGBO(247, 243, 237, 1),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
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
                      controller: emailController,
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
                      controller: passwordController,
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
                            !obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color.fromRGBO(247, 243, 237, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              SlidingNav(
                                builder: (context) => const ForgotPwdScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Your Password?",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: signInWithPwd,
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
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: const BorderSide(
                                      color: Color.fromRGBO(247, 243, 237, 1),
                                      width: 3.0),
                                ),
                              ),
                            ),
                            onPressed: googleSignIn,
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
              if (_isLoggingIn)
                const Positioned.fill(
                  child: Center(
                    child: ContainerLoadingAnimation(),
                  ),
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
