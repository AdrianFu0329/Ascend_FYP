import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserListTile extends StatefulWidget {
  final String userId;
  final Function(String)? onUserSelected;
  final bool? isSelected;

  const UserListTile({
    super.key,
    required this.userId,
    this.onUserSelected,
    this.isSelected,
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
          return Shimmer.fromColors(
            baseColor: Theme.of(context).cardColor,
            highlightColor: Colors.grey,
            child: ListTile(
              horizontalTitleGap: 12,
              leading: const CircleAvatar(
                radius: 27,
                backgroundColor: Colors.grey,
              ),
              title: Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";

          return ListTile(
            onTap: () {
              if (widget.onUserSelected != null) {
                widget.onUserSelected!(widget.userId);
              }
            },
            horizontalTitleGap: 12,
            leading: SizedBox(
              width: 40,
              child: Stack(
                children: [
                  ProfilePicture(
                    userId: widget.userId,
                    photoURL: photoUrl,
                    radius: 27,
                    onTap: () {},
                  ),
                  if (widget.isSelected != null && widget.isSelected!)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
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
