import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
  bool isLoading = false;

  @override
  void initState() {
    deleteChatsWithoutMessages();
    super.initState();
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

  String shortenMessage(String message, String type) {
    if (type == "image") {
      return "Image";
    } else {
      List<String> words = message.split(' ');
      if (words.length <= 5) {
        return message;
      } else {
        return '${words.sublist(0, 5).join(' ')}...';
      }
    }
  }

  Future<void> deleteChatsWithoutMessages() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('chats')
          .get();
      for (DocumentSnapshot chatDoc in chatSnapshot.docs) {
        CollectionReference messagesRef =
            chatDoc.reference.collection('messages');
        QuerySnapshot messagesSnapshot = await messagesRef.get();
        if (messagesSnapshot.docs.isEmpty) {
          await chatDoc.reference.delete();
          debugPrint('Deleted chat document with id: ${chatDoc.id}');
        }
      }
    } catch (e) {
      debugPrint('Failed to delete chat documents without messages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget chatCardLoading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey,
        child: ListTile(
          leading: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
          ),
          title: Container(
            width: 100,
            height: 10,
            color: Colors.grey,
          ),
          trailing: Container(
            width: 50,
            height: 10,
            color: Colors.grey,
          ),
        ),
      ),
    );
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

    return isLoading
        ? chatCardLoading()
        : FutureBuilder<Map<String, dynamic>>(
            future: getUserData(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return chatCardLoading();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userData = snapshot.data!;
                final username = userData["username"] ?? "Unknown";
                final photoUrl = userData["photoURL"] ?? "Unknown";
                final userFcmToken = userData["fcmToken"] ?? "Unknown";

                return GestureDetector(
                  onTap: () async {
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
                    stream: getChatData(widget.chatRoomId, currentUser.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData) {
                        deleteChatsWithoutMessages();
                        return Container();
                      } else {
                        var messageDoc = snapshot.data!.docs.first;
                        String lastMessage = messageDoc['message'] ?? '';
                        String shortenedMessage = shortenMessage(
                          lastMessage,
                          messageDoc['type'],
                        );

                        return Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: widget.hasRead
                              ? ListTile(
                                  leading: SizedBox(
                                    width: 50,
                                    child: ProfilePicture(
                                      userId: widget.userId,
                                      photoURL: photoUrl,
                                      radius: 25,
                                      onTap: () async {
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
                                  ),
                                  title: Text(
                                    username,
                                    style: usernameStyle,
                                  ),
                                  subtitle: Row(
                                    children: [
                                      (messageDoc['type'] == "image")
                                          ? Icon(
                                              Icons.image,
                                              color: Colors.grey[400],
                                            )
                                          : Container(),
                                      const SizedBox(width: 5),
                                      Text(
                                        shortenedMessage,
                                        style: messageStyle,
                                      ),
                                    ],
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
                                        width: 3.0,
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
                                  subtitle: Row(
                                    children: [
                                      (messageDoc['type'] == "image")
                                          ? const Icon(
                                              Icons.image,
                                              color: Color.fromRGBO(
                                                  247, 243, 237, 1),
                                            )
                                          : Container(),
                                      const SizedBox(width: 5),
                                      Text(
                                        shortenedMessage,
                                        style: unreadMessageStyle,
                                      ),
                                    ],
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
