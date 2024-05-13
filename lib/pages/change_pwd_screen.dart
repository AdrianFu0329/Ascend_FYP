import 'package:flutter/material.dart';

class ChangePwdScreen extends StatefulWidget {
  const ChangePwdScreen({super.key});

  @override
  State<ChangePwdScreen> createState() => _ChangePwdScreenState();
}

class _ChangePwdScreenState extends State<ChangePwdScreen> {
  bool passwordText = true;
  bool confirmPasswordText = true;
  bool passwordsMatch = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool passwordMatch() {
      return passwordController.text == confirmPasswordController.text;
    }

    bool isEditButtonEnabled() {
      return passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordMatch();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: passwordController,
              style: Theme.of(context).textTheme.titleMedium,
              obscureText: passwordText,
              onChanged: (value) {
                setState(() {
                  passwordText = value.isNotEmpty;
                  passwordsMatch = passwordMatch();
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
                    !passwordText ? Icons.visibility : Icons.visibility_off,
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
                      : passwordMatch()
                          ? 'Passwords match'
                          : 'Passwords do not match',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Merriweather Sans',
                    fontWeight: FontWeight.normal,
                    color: passwordMatch() ? Colors.green : Colors.red,
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
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                                color: const Color.fromRGBO(247, 243, 237, 1),
                                width: !isEditButtonEnabled() ? 1.0 : 3.0),
                          ),
                        ),
                      ),
                      onPressed: !isEditButtonEnabled() ? null : () {},
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
