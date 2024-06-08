import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final String userId;
  final Function(String, String, String)? onPress;
  const UserListTile({
    super.key,
    required this.userId,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";

          return ListTile(
            onTap: () {
              onPress == null ? () {} : onPress!(userId, username, photoUrl);
            },
            horizontalTitleGap: 12,
            leading: SizedBox(
              width: 40,
              child: ProfilePicture(
                userId: userId,
                photoURL: photoUrl,
                radius: 20,
                onTap: () {},
              ),
            ),
            title: Text(
              username,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
      },
    );
  }
}
