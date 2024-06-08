import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatefulWidget {
  final String userId;
  final Timestamp timestamp;
  final String chatRoomId;

  const ChatCard({
    super.key,
    required this.userId,
    required this.timestamp,
    required this.chatRoomId,
  });

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  String fromDateToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    // Check if the timestamp is today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Return the time only
      String formattedTime = DateFormat('h:mm a').format(dateTime);
      return formattedTime;
    } else {
      // Return the date only
      String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      return formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ContainerLoadingAnimation());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => ChatScreen(
                    receiverUserId: widget.userId,
                    receiverUsername: username,
                    receiverPhotoUrl: photoUrl,
                    chatRoomId: widget.chatRoomId,
                  ),
                ),
              );
            },
            child: Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfilePicture(
                        userId: widget.userId,
                        photoURL: photoUrl,
                        radius: 25,
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    fromDateToString(widget.timestamp),
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
