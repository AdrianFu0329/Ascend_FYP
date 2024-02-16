import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset(
              'lib/assets/images/welcome_img1.png',
            ),
            const SizedBox(height: 20),
            // Button for Google account login
            ElevatedButton.icon(
              onPressed: () {
                // Handle Google account login
              },
              icon: Image.asset(
                'lib/assets/images/google_logo.png',
                width: 30,
                height: 30,
              ),
              label: Text('Login with Google',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            // Button for email/password login
            ElevatedButton.icon(
              onPressed: () {
                // Handle email/password login
              },
              icon: const Icon(
                Icons.email,
                size: 30,
              ),
              label: Text(
                'Login with Email',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
