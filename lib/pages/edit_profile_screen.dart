import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/change_pwd_screen.dart';
import 'package:ascend_fyp/pages/profile_details_screen.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final String description;
  const EditProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 50),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color.fromRGBO(247, 243, 237, 1),
            width: 1.5,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Edit Profile',
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => ProfileDetailsScreen(
                        username: username,
                        email: email,
                        description: description,
                      ),
                    ),
                  );
                },
                style: buttonStyle,
                child: Row(
                  children: [
                    Image.asset(
                      "lib/assets/images/edit_profile.png",
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 16),
                    const Text('Profile Details'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(SlidingNav(
                      builder: (context) => const ChangePwdScreen()));
                },
                style: buttonStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "lib/assets/images/change_pwd.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 16),
                        const Text('Change Password'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
