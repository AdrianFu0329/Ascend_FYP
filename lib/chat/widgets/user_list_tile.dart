import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:flutter/material.dart';

class UserListTile extends StatefulWidget {
  final String userId;
  const UserListTile({
    super.key,
    required this.userId,
  });

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";
          final userFcmToken = userData["fcmToken"] ?? "Unknown";

          return ListTile(
            onTap: () {
              setState(() {
                ChatService().createChatRoom(
                  widget.userId,
                  username,
                  photoUrl,
                  userFcmToken,
                  context,
                );
              });
            },
            horizontalTitleGap: 12,
            leading: SizedBox(
              width: 40,
              child: ProfilePicture(
                userId: widget.userId,
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
