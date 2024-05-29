import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:flutter/material.dart';

class GroupMemberTile extends StatefulWidget {
  final String userId;
  final String photoURL;
  final String username;
  final String role;
  const GroupMemberTile({
    super.key,
    required this.userId,
    required this.photoURL,
    required this.username,
    required this.role,
  });

  @override
  State<GroupMemberTile> createState() => _GroupMemberTileState();
}

class _GroupMemberTileState extends State<GroupMemberTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        child: ProfilePicture(
          userId: widget.userId,
          photoURL: widget.photoURL,
          radius: 20,
          onTap: () {
            /*Navigator.of(context).push(
                                                  SlidingNav(
                                                    builder: (context) =>
                                                        
                                                  ),
                                                );*/
            // Group Member Profile Details Screen
          },
        ),
      ),
      title: Text(
        widget.username,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Text(
        widget.role,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
