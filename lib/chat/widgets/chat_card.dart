import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatefulWidget {
  final String userId;
  final Timestamp timestamp;
  final String chatRoomId;
  final bool hasRead;

  const ChatCard({
    super.key,
    required this.userId,
    required this.timestamp,
    required this.chatRoomId,
    required this.hasRead,
  });

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> updateIsRead(String chatRoomId) async {
    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

    try {
      DocumentSnapshot chatSnapshot = await chatRef.get();

      if (chatSnapshot.exists) {
        Map<String, dynamic> chatData =
            chatSnapshot.data() as Map<String, dynamic>;
        bool isSender = currentUser.uid == chatData["senderId"];
        if (isSender) {
          chatRef.update({
            'senderRead': true,
          });
        } else {
          chatRef.update({
            'receiverRead': true,
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to update read status for user: $e");
    }
  }

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

  String shortenMessage(String message) {
    List<String> words = message.split(' ');
    if (words.length <= 5) {
      return message;
    } else {
      return '${words.sublist(0, 5).join(' ')}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle usernameStyle = TextStyle(
      fontSize: 13,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey[400],
    );

    TextStyle unreadUsernameStyle = const TextStyle(
      fontSize: 13,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    TextStyle messageStyle = TextStyle(
      fontSize: 11,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey[400],
    );

    TextStyle unreadMessageStyle = const TextStyle(
      fontSize: 11,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    TextStyle timestampStyle = TextStyle(
      fontSize: 8,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Colors.grey[400],
    );

    TextStyle unreadTimestampStyle = const TextStyle(
      fontSize: 8,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

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
          final userFcmToken = userData["fcmToken"] ?? "Unknown";

          return GestureDetector(
            onTap: () async {
              await updateIsRead(widget.chatRoomId);
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => ChatScreen(
                    receiverUserId: widget.userId,
                    receiverUsername: username,
                    receiverPhotoUrl: photoUrl,
                    receiverFcmToken: userFcmToken,
                    chatRoomId: widget.chatRoomId,
                  ),
                ),
              );
            },
            child: StreamBuilder<QuerySnapshot>(
              stream: getChatData(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingAnimation(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  var messageDoc = snapshot.data!.docs.first;
                  String lastMessage = messageDoc['message'] ?? '';
                  String shortenedMessage = shortenMessage(lastMessage);

                  return Card(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: widget.hasRead
                        ? ListTile(
                            leading: ProfilePicture(
                              userId: widget.userId,
                              photoURL: photoUrl,
                              radius: 25,
                              onTap: () async {
                                await updateIsRead(widget.chatRoomId);
                                Navigator.of(context).push(
                                  SlidingNav(
                                    builder: (context) => ChatScreen(
                                      receiverUserId: widget.userId,
                                      receiverUsername: username,
                                      receiverPhotoUrl: photoUrl,
                                      receiverFcmToken: userFcmToken,
                                      chatRoomId: widget.chatRoomId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            title: Text(
                              username,
                              style: usernameStyle,
                            ),
                            subtitle: Text(
                              shortenedMessage,
                              style: messageStyle,
                            ),
                            trailing: Text(
                              fromDateToString(widget.timestamp),
                              style: timestampStyle,
                            ),
                          )
                        : ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5.0,
                                ),
                              ),
                              child: ProfilePicture(
                                userId: widget.userId,
                                photoURL: photoUrl,
                                radius: 25,
                                onTap: () {},
                              ),
                            ),
                            title: Text(
                              username,
                              style: unreadUsernameStyle,
                            ),
                            subtitle: Text(
                              shortenedMessage,
                              style: unreadMessageStyle,
                            ),
                            trailing: Text(
                              fromDateToString(widget.timestamp),
                              style: unreadTimestampStyle,
                            ),
                          ),
                  );
                }
              },
            ),
          );
        }
      },
    );
  }
}
