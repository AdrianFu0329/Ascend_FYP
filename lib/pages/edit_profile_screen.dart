import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/change_prof_pic.dart';
import 'package:ascend_fyp/pages/change_pwd_screen.dart';
import 'package:ascend_fyp/pages/profile_details_screen.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
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
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String username;
  late String email;
  late String description;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    email = widget.email;
    description = widget.description;
  }

  Future<void> navigateAndUpdate(BuildContext context) async {
    final result = await Navigator.of(context).push(
      SlidingNav(
        builder: (context) => ProfileDetailsScreen(
          username: username,
          email: email,
          description: description,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        username = result['username'];
        email = result['email'];
        description = result['description'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 50),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
        leading: PopScope(
          canPop: false,
          onPopInvoked: ((didPop) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop({
              'username': username,
              'email': email,
              'description': description,
            });
          }),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            onPressed: () {
              Navigator.of(context).pop({
                'username': username,
                'email': email,
                'description': description,
              });
            },
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  navigateAndUpdate(context);
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
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => const ChangePwdScreen(),
                    ),
                  );
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => const ChangeProfPic(),
                    ),
                  );
                },
                style: buttonStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "lib/assets/images/profile_pic.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 16),
                        const Text('Change Profile Picture'),
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
