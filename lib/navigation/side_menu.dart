import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/pages/user_events_screen.dart';
import 'package:ascend_fyp/pages/user_groups_screen.dart';
import 'package:ascend_fyp/pages/welcome_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:ascend_fyp/widgets/side_menu_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: IconButton(
                  highlightColor: const Color.fromRGBO(194, 0, 0, 1),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(194, 0, 0, 1),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                height: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfilePicture(
                            userId: currentUser.uid,
                            photoURL: photoUrl,
                            radius: 20,
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          Text(
                            username,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        color: Color.fromRGBO(247, 243, 237, 1),
                        thickness: 1,
                      ),
                      const SideMenuTile(
                        title: "Events",
                        assetPath: "lib/assets/images/events.png",
                        navScreen: UserEventsScreen(),
                      ),
                      const SideMenuTile(
                        title: "Groups",
                        assetPath: "lib/assets/images/groups.png",
                        navScreen: UserGroupsScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
