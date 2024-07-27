import 'dart:async';
import 'dart:io';

import 'package:ascend_fyp/chat/screens/group_chat_screen.dart';
import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/chat/widgets/user_list_tile.dart';
import 'package:ascend_fyp/general%20widgets/custom_text_field.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class CreateGroupChatScreen extends StatefulWidget {
  final List<String> groupMemberList;
  const CreateGroupChatScreen({super.key, required this.groupMemberList});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController titleController = TextEditingController();
  late AnimationController animationController;
  File? _selectedImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final ValueNotifier<int> titleCharCount = ValueNotifier<int>(0);
  final int titleMaxLength = 20;

  List<String> groupMembersId = [];
  late List<String> memberFCMTokens;

  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      titleCharCount.value = titleController.text.length;
    });
    animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.stop();
          animationController.animateTo(0.8);
        }
      });
    _initializeGroupMembers();
  }

  Future<void> _initializeGroupMembers() async {
    setState(() {
      _isLoading = true;
    });
    memberFCMTokens = await getMemberFCMTokens();
    try {
      // Add current user's data
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, dynamic> currentUserData =
            await getUserData(currentUser.uid);

        // Add current user's UID and FCM token to the respective lists
        if (currentUserData['fcmToken'].isNotEmpty) {
          memberFCMTokens.add(currentUserData['fcmToken']);
        }
        groupMembersId.add(currentUser.uid);
      }

      // Add other group members' id
      for (String memberId in widget.groupMemberList) {
        groupMembersId.add(memberId);
      }
    } catch (error) {
      showMessage('Error initializing group members', false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    titleCharCount.dispose();
    animationController.dispose();
    super.dispose();
  }

  void showMessage(String message, bool completed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: completed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      "lib/assets/lottie/check.json",
                      width: 150,
                      height: 150,
                      controller: animationController,
                      onLoaded: (composition) {
                        animationController.duration = composition.duration;
                        animationController.forward(from: 0.0);
                        final durationToStop = composition.duration * 0.8;
                        Timer(durationToStop, () {
                          animationController.stop();
                          animationController.value = 0.8;
                        });
                      },
                    ),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                )
              : Text(
                  message,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  bool validateGroupChat() {
    if (titleController.text.trim().isEmpty) {
      showMessage('Please enter a title.', false);
      return false;
    }
    if (_selectedImage == null) {
      showMessage('Please select a group chat image.', false);
      return false;
    }
    return true;
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<String> uploadImage(String chatroomId, File image) async {
    try {
      final String fileName = '$chatroomId.jpeg';
      final Reference reference = FirebaseStorage.instance
          .ref()
          .child('group_chats/$chatroomId/$fileName');
      final UploadTask uploadTask = reference.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      debugPrint('Error uploading image: $error');
      showMessage('There was an error uploading the image, try again!', false);
      return "";
    }
  }

  Future<List<String>> getMemberFCMTokens() async {
    List<String> fcmTokens = [];
    for (String memberId in widget.groupMemberList) {
      Map<String, dynamic> userData = await getUserData(memberId);
      String fcmToken = userData['fcmToken'];
      if (fcmToken.isNotEmpty) {
        fcmTokens.add(fcmToken);
      }
    }
    return fcmTokens;
  }

  Future<void> createGroupChat() async {
    if (validateGroupChat()) {
      setState(() {
        _isLoading = true;
      });

      final chatRoomId = await ChatService().createGroupChatRoom(
        groupMembersId,
        titleController.text.trim(),
        memberFCMTokens,
      );

      if (chatRoomId != null) {
        if (_selectedImage != null) {
          String downloadURL = await uploadImage(chatRoomId, _selectedImage!);
          // Update the chat room with the group picture URL
          await FirebaseFirestore.instance
              .collection('group_chats')
              .doc(chatRoomId)
              .update({'groupPictureUrl': downloadURL});

          showMessage('Group chat created successfully', true);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(
            SlidingNav(
              builder: (context) => GroupChatScreen(
                groupPicUrl: downloadURL,
                groupName: titleController.text.trim(),
                chatRoomId: chatRoomId,
              ),
            ),
          );
        }
      } else {
        showMessage('Error creating group chat', false);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side:
              const BorderSide(color: Color.fromRGBO(194, 0, 0, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: ElevatedButton(
              onPressed: createGroupChat,
              style: buttonStyle,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              File? image = await pickImage();
                              if (image != null) {
                                setState(() {
                                  _selectedImage = image;
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null,
                                child: _selectedImage == null
                                    ? const Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                        size: 25,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: titleController,
                            hintText: "Group Name",
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(titleMaxLength),
                            ],
                            charCountNotifier: titleCharCount,
                            maxLength: titleMaxLength,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36.0),
                    Text(
                      'Group Members',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap:
                          true, // To make ListView fit inside the Column
                      itemCount: groupMembersId.length,
                      itemBuilder: (context, index) {
                        final memberId = groupMembersId[index];
                        return UserListTile(
                          userId: memberId,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(
                  child: CustomLoadingAnimation(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
