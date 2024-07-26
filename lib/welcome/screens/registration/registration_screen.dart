import 'dart:async';

import 'package:ascend_fyp/auth_service/AuthService.dart';
import 'package:ascend_fyp/general%20widgets/custom_text_field.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  bool passwordText = true;
  bool confirmPasswordText = true;
  bool passwordsMatch = false;
  bool isRegistering = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.stop();
          animationController.animateTo(0.8);
        }
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  bool _passwordMatch() {
    return passwordController.text == confirmPasswordController.text;
  }

  bool _isRegisterButtonEnabled() {
    return usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        _passwordMatch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Registration",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  CustomTextField(
                    controller: usernameController,
                    hintText: "Username",
                  ),
                  const SizedBox(height: 35),
                  CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                  ),
                  const SizedBox(height: 35),
                  TextField(
                    controller: passwordController,
                    style: Theme.of(context).textTheme.titleMedium,
                    obscureText: passwordText,
                    onChanged: (value) {
                      setState(() {
                        passwordText = value.isNotEmpty;
                        passwordsMatch = _passwordMatch();
                      });
                    },
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
                            passwordText = !passwordText;
                          });
                        },
                        icon: Icon(
                          !passwordText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromRGBO(247, 243, 237, 1),
                        ),
                      ),
                    ),
                    cursorColor: const Color.fromRGBO(247, 243, 237, 1),
                  ),
                  const SizedBox(height: 35),
                  TextField(
                    controller: confirmPasswordController,
                    style: Theme.of(context).textTheme.titleMedium,
                    obscureText: confirmPasswordText,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
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
                            confirmPasswordText = !confirmPasswordText;
                          });
                        },
                        icon: Icon(
                          !confirmPasswordText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromRGBO(247, 243, 237, 1),
                        ),
                      ),
                    ),
                    cursorColor: const Color.fromRGBO(247, 243, 237, 1),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        passwordController.text.isEmpty &&
                                confirmPasswordController.text.isEmpty
                            ? ''
                            : _passwordMatch()
                                ? 'Passwords match'
                                : 'Passwords do not match',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Merriweather Sans',
                          fontWeight: FontWeight.normal,
                          color: _passwordMatch() ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: IconButton(
                            highlightColor: Colors.greenAccent,
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      color: const Color.fromRGBO(
                                          247, 243, 237, 1),
                                      width: !_isRegisterButtonEnabled()
                                          ? 1.0
                                          : 3.0),
                                ),
                              ),
                            ),
                            onPressed: !_isRegisterButtonEnabled()
                                ? null
                                : () async {
                                    setState(() {
                                      isRegistering = true;
                                    });
                                    String message =
                                        await AuthService().signUpWithPwd(
                                      emailController.text,
                                      passwordController.text,
                                      usernameController.text,
                                    );
                                    if (message == "Registration Successful") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Lottie.asset(
                                                "lib/assets/lottie/check.json",
                                                width: 150,
                                                height: 150,
                                                controller: animationController,
                                                onLoaded: (composition) {
                                                  animationController.duration =
                                                      composition.duration;
                                                  animationController.forward(
                                                      from: 0.0);
                                                  final durationToStop =
                                                      composition.duration *
                                                          0.8;
                                                  Timer(durationToStop, () {
                                                    animationController.stop();
                                                    animationController.value =
                                                        0.8;
                                                  });
                                                },
                                              ),
                                              Text(
                                                message,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (message ==
                                        "Registration Failed") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                          "Registration failed!\nPlease try again!",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        )),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                    Navigator.of(context).pop();
                                  },
                            icon: Image.asset(
                              'lib/assets/images/register.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRegistering)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0),
                child: const Center(
                  child: CustomLoadingAnimation(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
