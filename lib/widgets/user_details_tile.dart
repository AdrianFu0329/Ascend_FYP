import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:flutter/material.dart';

class UserDetailsTile extends StatefulWidget {
  final String userId;
  final String photoURL;
  final String username;
  final Widget trailing;
  const UserDetailsTile({
    super.key,
    required this.userId,
    required this.photoURL,
    required this.username,
    required this.trailing,
  });

  @override
  State<UserDetailsTile> createState() => _UserDetailsTileState();
}

class _UserDetailsTileState extends State<UserDetailsTile> {
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
      trailing: widget.trailing,
    );
  }
}
