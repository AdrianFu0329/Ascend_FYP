import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/chat/widgets/chat_bubble.dart';
import 'package:ascend_fyp/database/firebase_notifications.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/profile/screens/details/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverUserId;
  final String receiverUsername;
  final String receiverFcmToken;
  final String receiverPhotoUrl;

  const ChatScreen({
    super.key,
    required this.receiverUserId,
    required this.receiverUsername,
    required this.receiverPhotoUrl,
    required this.chatRoomId,
    required this.receiverFcmToken,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final currentUserphotoURL =
      FirebaseAuth.instance.currentUser!.photoURL ?? "Unknown";
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    updateIsRead(widget.chatRoomId);
    _scrollToEnd();
  }

  Future<void> updateIsRead(String chatRoomId) async {
    DocumentReference currentUserChatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .doc(chatRoomId);

    DocumentReference receiverChatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverUserId)
        .collection('chats')
        .doc(chatRoomId);

    try {
      DocumentSnapshot currentUserChatSnapshot = await currentUserChatRef.get();

      if (currentUserChatSnapshot.exists) {
        Map<String, dynamic> chatData =
            currentUserChatSnapshot.data() as Map<String, dynamic>;
        bool isSender = currentUser.uid == chatData["senderId"];
        if (isSender) {
          currentUserChatRef.update({
            'senderRead': true,
          });
        } else {
          currentUserChatRef.update({
            'receiverRead': true,
          });
        }
      }

      DocumentSnapshot receiverChatSnapshot = await receiverChatRef.get();

      if (receiverChatSnapshot.exists) {
        Map<String, dynamic> chatData =
            receiverChatSnapshot.data() as Map<String, dynamic>;
        bool isSender = currentUser.uid == chatData["senderId"];
        if (isSender) {
          receiverChatRef.update({
            'senderRead': true,
          });
        } else {
          receiverChatRef.update({
            'receiverRead': true,
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to update read status for user: $e");
    }
  }

  void sendMessage(String message) async {
    await chatService.sendMessage(
      widget.receiverUserId,
      message,
      widget.chatRoomId,
    );
      FirebaseNotifications.sendNotificaionToSelectedDriver(
        widget.receiverFcmToken,
        "Message",
        "${currentUser.displayName}: $message",
        'chat',
      );

    _scrollToEnd();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> deleteChatsWithoutMessages() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) {
        if (didPop) {
          return;
        }
        deleteChatsWithoutMessages();
        Navigator.pop(context);
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: [
              ProfilePicture(
                userId: widget.receiverUserId,
                photoURL: widget.receiverPhotoUrl,
                radius: 20,
                onTap: () {
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => UserProfileScreen(
                        userId: widget.receiverUserId,
                        isCurrentUser: false,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => UserProfileScreen(
                        userId: widget.receiverUserId,
                        isCurrentUser: false,
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.receiverUsername,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            onPressed: () {
              deleteChatsWithoutMessages();
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget chatTextField(TextEditingController controller) {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: 5,
        cursorColor: const Color.fromRGBO(247, 243, 237, 1),
        controller: controller,
        style: Theme.of(context).textTheme.bodySmall,
        decoration: InputDecoration(
          hintText: 'Enter Message',
          hintStyle: Theme.of(context).textTheme.bodySmall,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getMessages(
        widget.receiverUserId,
        firebaseAuth.currentUser!.uid,
        widget.chatRoomId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text(
              'Loading...',
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToEnd();
          });

          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: (data['senderId'] == firebaseAuth.currentUser!.uid)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ChatBubble(
                        message: data['message'],
                        isCurrentUser:
                            (data['senderId'] == firebaseAuth.currentUser!.uid),
                      ),
                      Text(
                        fromDateToString(data['timestamp']),
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                  ),
                  const SizedBox(width: 5),
                  ProfilePicture(
                    userId: firebaseAuth.currentUser!.uid,
                    photoURL: currentUserphotoURL,
                    radius: 18,
                    onTap: () {},
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfilePicture(
                    userId: widget.receiverUserId,
                    photoURL: widget.receiverPhotoUrl,
                    radius: 18,
                    onTap: () {},
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChatBubble(
                        message: data['message'],
                        isCurrentUser:
                            (data['senderId'] == firebaseAuth.currentUser!.uid),
                      ),
                      Text(
                        fromDateToString(data['timestamp']),
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: chatTextField(
              messageController,
            ),
          ),
          IconButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                String message = messageController.text;
                messageController.clear();
                sendMessage(message);
              }
            },
            icon: CircleAvatar(
              backgroundColor: const Color.fromRGBO(247, 243, 237, 1),
              radius: 25,
              child: Icon(
                Icons.send_rounded,
                size: 30,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
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
}
