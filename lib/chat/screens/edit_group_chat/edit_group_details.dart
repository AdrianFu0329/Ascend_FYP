import 'dart:async';
import 'dart:io';

import 'package:ascend_fyp/general%20widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class EditGroupDetails extends StatefulWidget {
  final String chatRoomId;
  final String groupChatName;
  final String groupChatPicURL;
  const EditGroupDetails({
    super.key,
    required this.chatRoomId,
    required this.groupChatName,
    required this.groupChatPicURL,
  });

  @override
  State<EditGroupDetails> createState() => _EditGroupDetailsState();
}

class _EditGroupDetailsState extends State<EditGroupDetails>
    with SingleTickerProviderStateMixin {
  TextEditingController titleController = TextEditingController();
  late AnimationController animationController;
  final currentUser = FirebaseAuth.instance.currentUser!;
  File? _selectedImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ValueNotifier<int> titleCharCount;
  final int titleMaxLength = 20;
  late String existingPicURL;
  late String newChatName;
  late String newPicURL;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.stop();
          animationController.animateTo(0.8);
        }
      });

    titleController.text = widget.groupChatName;
    titleCharCount = ValueNotifier<int>(widget.groupChatName.length);
    existingPicURL = widget.groupChatPicURL;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void showMessage(String message, bool completed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: completed == true
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
                Navigator.of(context).pop();
                if (completed) {
                  Navigator.of(context).pop({
                    'newChatName': newChatName,
                    'newPicURL': newPicURL,
                  });
                }
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

  Future<void> updateGroupChatDetails() async {
    String newImageUrl = existingPicURL;

    if (_selectedImage != null) {
      newImageUrl = await uploadImage(widget.chatRoomId, _selectedImage!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.chatRoomId)
          .update({
        'groupChatName': titleController.text.trim(),
        'groupPictureUrl': newImageUrl,
      });
      setState(() {
        newChatName = titleController.text.trim();
        newPicURL = newImageUrl;
      });
      showMessage('Group details updated successfully!', true);
    } catch (error) {
      debugPrint('Error updating group chat details: $error');
      showMessage(
          'There was an error updating the group chat details, try again!',
          false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget makeDismissible({required Widget child}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: child,
          ),
        );

    return makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.25,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Group Details",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      bool validate = validateGroupChat();
                      if (validate) {
                        updateGroupChatDetails();
                      }
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
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
                                    setState(() {
                                      _selectedImage = image;
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 65,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _selectedImage != null
                                          ? FileImage(_selectedImage!)
                                          : NetworkImage(widget.groupChatPicURL)
                                              as ImageProvider,
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
                                  hintText: "Title",
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(
                                        titleMaxLength),
                                  ],
                                  charCountNotifier: titleCharCount,
                                  maxLength: titleMaxLength,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
