import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/user_details_tile.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/profile/screens/details/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FollowerListTab extends StatefulWidget {
  final List<dynamic> list;
  const FollowerListTab({super.key, required this.list});

  @override
  State<FollowerListTab> createState() => _FollowerListTabState();
}

class _FollowerListTabState extends State<FollowerListTab> {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: getUserData(widget.list[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CustomLoadingAnimation(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text('No user data available'),
                );
              }

              Map<String, dynamic> userData = snapshot.data!;
              bool isCurrentUser =
                  widget.list[index] == currentUser!.uid ? true : false;

              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      SlidingNav(
                        builder: (context) => UserProfileScreen(
                          userId: widget.list[index],
                          isCurrentUser: isCurrentUser,
                        ),
                      ),
                    );
                  },
                  child: UserDetailsTile(
                    userId: widget.list[index],
                    photoURL: userData['photoURL'],
                    username: userData['username'],
                    trailing: const SizedBox(
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
