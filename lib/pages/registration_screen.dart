import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool passwordText = true;
  bool confirmPasswordText = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _passwordMatch() {
    return passwordController.text == confirmPasswordController.text;
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 75),
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
            const SizedBox(height: 50),
            TextField(
              controller: passwordController,
              style: Theme.of(context).textTheme.titleMedium,
              obscureText: passwordText,
              onChanged: (value) {
                setState(() {});
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
                    !passwordText ? Icons.visibility : Icons.visibility_off,
                    color: const Color.fromRGBO(247, 243, 237, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
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
                      onPressed: () {},
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
    );
  }
}
