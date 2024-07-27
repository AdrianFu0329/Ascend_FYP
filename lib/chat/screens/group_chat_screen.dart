import 'dart:io';

import 'package:ascend_fyp/chat/screens/edit_group_chat/edit_group_details.dart';
import 'package:ascend_fyp/chat/screens/edit_group_chat/edit_members.dart';
import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/chat/widgets/chat_bubble.dart';
import 'package:ascend_fyp/database/firebase_notifications.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String groupName;
  final String groupPicUrl;
  final Function(bool)? toRefresh;

  const GroupChatScreen({
    super.key,
    required this.groupPicUrl,
    required this.chatRoomId,
    this.toRefresh,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final currentUserphotoURL =
      FirebaseAuth.instance.currentUser!.photoURL ?? "Unknown";
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final ImagePicker _picker = ImagePicker();
  List<QuerySnapshot> chatMessages = [];
  late String chatName;
  late String picURL;

  @override
  void initState() {
    updateIsRead(widget.chatRoomId);
    chatName = widget.groupName;
    picURL = widget.groupPicUrl;
    super.initState();
    _scrollToEnd();
  }

  void showMessage(String message, bool confirm,
      {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm) {
                  if (onYesPressed != null) {
                    onYesPressed();
                  }
                } else {
                  if (onOKPressed != null) {
                    onOKPressed();
                  }
                }
              },
              child: Text(
                confirm ? 'Yes' : 'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            confirm
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Future<void> updateIsRead(String chatRoomId) async {
    try {
      DocumentReference groupChatRef =
          FirebaseFirestore.instance.collection('group_chats').doc(chatRoomId);

      DocumentSnapshot groupChatSnapshot = await groupChatRef.get();

      if (groupChatSnapshot.exists) {
        Map<String, dynamic> data =
            groupChatSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> membersMap =
            data['memberMap'] as Map<String, dynamic>;

        if (membersMap.containsKey(currentUser.uid)) {
          membersMap[currentUser.uid] = true;
          await groupChatRef.update({
            'memberMap': membersMap,
          });
        }
      } else {
        debugPrint('Group chat does not exist');
      }
    } catch (e) {
      debugPrint("Failed to update read status for user: $e");
    }
  }

  void sendTextMessage(String message) async {
    // Send text message to the group chat
    await chatService.sendGroupTextMessage(
      message,
      widget.chatRoomId,
    );

    // Get the FCM tokens from the group_chat document
    DocumentReference grpChatRef = FirebaseFirestore.instance
        .collection('group_chats')
        .doc(widget.chatRoomId);

    try {
      DocumentSnapshot grpChatSnapshot = await grpChatRef.get();

      if (grpChatSnapshot.exists) {
        Map<String, dynamic> grpChatData =
            grpChatSnapshot.data() as Map<String, dynamic>;
        List<String> memberFcmTokens =
            List<String>.from(grpChatData["memberFcmToken"]);

        // Send notification to each FCM token
        for (String fcmToken in memberFcmTokens) {
          FirebaseNotifications.sendNotificaionToSelectedDriver(
            fcmToken,
            "Message",
            "${currentUser.displayName}: $message",
            'chat',
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to send notifications: $e");
    }
    _scrollToEnd();
  }

  void sendImageMessage(File imageFile) async {
    String imageUrl = await chatService.uploadImage(imageFile);
    await chatService.sendGroupImageMessage(
      imageUrl,
      widget.chatRoomId,
    );

    // Get the FCM tokens from the group_chat document
    DocumentReference grpChatRef = FirebaseFirestore.instance
        .collection('group_chats')
        .doc(widget.chatRoomId);

    try {
      DocumentSnapshot grpChatSnapshot = await grpChatRef.get();

      if (grpChatSnapshot.exists) {
        Map<String, dynamic> grpChatData =
            grpChatSnapshot.data() as Map<String, dynamic>;
        List<String> memberFcmTokens =
            List<String>.from(grpChatData["memberFcmToken"]);

        // Send notification to each FCM token
        for (String fcmToken in memberFcmTokens) {
          FirebaseNotifications.sendNotificaionToSelectedDriver(
            fcmToken,
            "Image",
            "${currentUser.displayName} sent an image",
            'chat',
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to send notifications: $e");
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

  Future<void> deleteChatsWithoutMessages() async {
    try {
      QuerySnapshot chatSnapshot =
          await FirebaseFirestore.instance.collection('group_chats').get();
      for (DocumentSnapshot chatDoc in chatSnapshot.docs) {
        CollectionReference messagesRef =
            chatDoc.reference.collection('messages');
        QuerySnapshot messagesSnapshot = await messagesRef.get();
        if (messagesSnapshot.docs.length <= 1) {
          await chatDoc.reference.delete();
          debugPrint('Deleted chat document with id: ${chatDoc.id}');
        }
      }
    } catch (e) {
      debugPrint('Failed to delete chat documents without messages: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await showModalBottomSheet<XFile>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color.fromRGBO(247, 243, 237, 1),
              ),
              title: Text(
                'Pick from Gallery',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () async {
                final galleryFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, galleryFile);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color.fromRGBO(247, 243, 237, 1),
              ),
              title: Text(
                'Take a Photo',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () async {
                final cameraFile =
                    await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, cameraFile);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      sendImageMessage(imageFile);
    }
  }

  void showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: Image.network(imageUrl),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void modalBottomSheet(Widget screen) async {
    Map<String, dynamic>? chatData = await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => screen,
    );

    if (chatData != null) {
      setState(() {
        chatName = chatData['newChatName'];
        picURL = chatData['newPicURL'];
      });
    }
  }

  void _onMenuItemSelected(String value) async {
    switch (value) {
      case 'edit_details':
        modalBottomSheet(EditGroupDetails(
          chatRoomId: widget.chatRoomId,
          groupChatName: chatName,
          groupChatPicURL: picURL,
        ));
        break;
      case 'edit_members':
        DocumentReference groupChatRef = FirebaseFirestore.instance
            .collection('group_chats')
            .doc(widget.chatRoomId);

        DocumentSnapshot groupChatSnapshot = await groupChatRef.get();

        if (groupChatSnapshot.exists) {
          Map<String, dynamic> data =
              groupChatSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> membersMap =
              data['memberMap'] as Map<String, dynamic>;
          List<String> existingGrpMembers = membersMap.keys.toList();

          modalBottomSheet(EditMembers(
            existingGrpMembers: existingGrpMembers,
            chatRoomId: widget.chatRoomId,
          ));
        } else {
          debugPrint('Group chat does not exist');
        }
        break;
      case 'quit_group':
        showMessage(
          "Are you sure you want to quit this group chat?",
          true,
          onYesPressed: () {
            quitGroupChat();
          },
        );
        break;
    }
  }

  Future<void> quitGroupChat() async {
    try {
      DocumentReference groupChatRef = FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.chatRoomId);
      DocumentSnapshot groupChatSnapshot = await groupChatRef.get();
      final userData = await getUserData(currentUser.uid);
      String userFCMToken = userData['fcmToken'];

      if (groupChatSnapshot.exists) {
        Map<String, dynamic> data =
            groupChatSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> membersMap =
            data['memberMap'] as Map<String, dynamic>;
        List<dynamic> memberFCMToken = data['memberFCMToken'] as List<dynamic>;

        if (membersMap.containsKey(currentUser.uid)) {
          membersMap.remove(currentUser.uid);
          if (memberFCMToken.contains(userFCMToken)) {
            memberFCMToken.remove(userFCMToken);
            await groupChatRef.update({
              'memberMap': membersMap,
              'memberFCMToken': memberFCMToken,
            });
            showMessage("Exited successfully from Group Chat", false,
                onOKPressed: () {
              Navigator.pop(context);
            });
          }
        }
      } else {
        debugPrint('Group chat does not exist');
      }
    } catch (e) {
      debugPrint("Failed to quit group chat: $e");
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
        setState(() {
          if (widget.toRefresh != null) {
            widget.toRefresh!(true);
          }
        });
        Navigator.of(context).pop();
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundImage: NetworkImage(picURL),
              ),
              const SizedBox(width: 16),
              Text(
                chatName,
                style: Theme.of(context).textTheme.bodyLarge,
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
              Navigator.of(context).pop(true);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color.fromRGBO(247, 243, 237, 1),
              ),
              onSelected: _onMenuItemSelected,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'edit_details',
                    child: Text('Edit Chat Details'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit_members',
                    child: Text('Edit Chat Members'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'quit_group',
                    child: Text('Quit Group'),
                  ),
                ];
              },
            ),
          ],
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
      stream: chatService.getGroupMessages(
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

    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(data['senderId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading user data'));
        } else {
          final userData = snapshot.data!;
          return Container(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: (data['senderId'] == firebaseAuth.currentUser!.uid)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (data['type'] == 'system')
                          const SizedBox.shrink()
                        else if (data['type'] == 'text')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ChatBubble(
                                message: data['message'],
                                isCurrentUser: (data['senderId'] ==
                                    firebaseAuth.currentUser!.uid),
                              ),
                              Text(
                                fromDateToString(data['timestamp']),
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            ],
                          )
                        else if (data['type'] == 'image')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showFullScreenImage(data['message']);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                    maxHeight: 250,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.network(
                                      data['message'],
                                      width: 200,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              backgroundColor:
                                                  Theme.of(context).cardColor,
                                              color: Colors.red,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                fromDateToString(data['timestamp']),
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            ],
                          ),
                        const SizedBox(width: 5),
                        data['type'] == 'system'
                            ? const SizedBox.shrink()
                            : ProfilePicture(
                                userId: firebaseAuth.currentUser!.uid,
                                photoURL: userData['photoURL'],
                                radius: 18,
                                onTap: () {},
                              ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            data['type'] == 'system'
                                ? const SizedBox.shrink()
                                : ProfilePicture(
                                    userId: data['senderId'],
                                    photoURL: userData['photoURL'],
                                    radius: 18,
                                    onTap: () {},
                                  ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        if (data['type'] == 'system')
                          const SizedBox.shrink()
                        else if (data['type'] == 'text')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ChatBubble(
                                message: data['message'],
                                isCurrentUser: (data['senderId'] ==
                                    firebaseAuth.currentUser!.uid),
                              ),
                              Text(
                                fromDateToString(data['timestamp']),
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            ],
                          )
                        else if (data['type'] == 'image')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showFullScreenImage(data['message']);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                    maxHeight: 250,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.network(
                                      data['message'],
                                      width: 200,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              backgroundColor:
                                                  Theme.of(context).cardColor,
                                              color: Colors.red,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
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
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_photo_alternate,
              size: 30,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            onPressed: pickImage,
          ),
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
                sendTextMessage(message);
              }
            },
            icon: CircleAvatar(
              backgroundColor: const Color.fromRGBO(247, 243, 237, 1),
              radius: 25,
              child: Icon(
                Icons.send_rounded,
                size: 25,
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
