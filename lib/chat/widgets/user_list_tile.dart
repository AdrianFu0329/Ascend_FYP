import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> _findExistingChatRoom(
      String currentUserId, String selectedUserId) async {
    QuerySnapshot currentUserChats = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .get();

    QuerySnapshot selectedUserChats = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserId)
        .collection('chats')
        .get();

    for (var doc in currentUserChats.docs) {
      if (doc.id.contains(selectedUserId)) {
        return doc.id;
      }
    }

    for (var doc in selectedUserChats.docs) {
      if (doc.id.contains(currentUserId)) {
        // Copy the chat room to the current user's document if it exists in the selected user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('chats')
            .doc(doc.id)
            .set(doc.data() as Map<String, dynamic>);
        return doc.id;
      }
    }

    return null;
  }

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
            onTap: () async {
              String? existingChatRoomId =
                  await _findExistingChatRoom(currentUser!.uid, widget.userId);

              if (existingChatRoomId != null) {
                // Use the existing chat room
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  SlidingNav(
                    builder: (context) => ChatScreen(
                      receiverUserId: widget.userId,
                      receiverUsername: username,
                      receiverPhotoUrl: photoUrl,
                      chatRoomId: existingChatRoomId,
                      receiverFcmToken: userFcmToken,
                    ),
                  ),
                );
              } else {
                // Create a new chat room
                ChatService().createChatRoom(
                  widget.userId,
                  username,
                  photoUrl,
                  userFcmToken,
                  context,
                );
              }
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
