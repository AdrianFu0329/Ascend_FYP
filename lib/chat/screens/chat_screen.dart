import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/chat/widgets/chat_bubble.dart';
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
  final String receiverPhotoUrl;

  const ChatScreen({
    super.key,
    required this.receiverUserId,
    required this.receiverUsername,
    required this.receiverPhotoUrl,
    required this.chatRoomId,
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

  @override
  void initState() {
    super.initState();
    _scrollToEnd();
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(
        widget.receiverUserId,
        messageController.text,
        widget.chatRoomId,
      );

      messageController.clear();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget chatTextField(TextEditingController controller) {
    return Expanded(
      child: TextField(
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
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send_rounded,
              size: 30,
              color: Color.fromRGBO(247, 243, 237, 1),
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
