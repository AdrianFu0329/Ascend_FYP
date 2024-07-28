import 'dart:async';

import 'package:ascend_fyp/chat/widgets/user_list_tile.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EditMembers extends StatefulWidget {
  final String chatRoomId;
  final List<String> existingGrpMembers;
  const EditMembers({
    super.key,
    required this.existingGrpMembers,
    required this.chatRoomId,
  });

  @override
  State<EditMembers> createState() => _EditMembersState();
}

class _EditMembersState extends State<EditMembers>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  String searchUsername = "";
  TextEditingController searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  ValueNotifier<Set<String>> selectedUserIds = ValueNotifier<Set<String>>({});
  List<String> newGrpMembers = [];

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
    selectedUserIds.value = Set<String>.from(widget.existingGrpMembers);
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

  Future<void> updateGroupMembers(List<String> selectedUserIds) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final groupDoc =
          firestore.collection('group_chats').doc(widget.chatRoomId);

      // Get existing data
      final groupData = await groupDoc.get();
      final memberMap = Map<String, bool>.from(groupData['memberMap'] ?? {});
      final memberFCMTokens =
          List<String>.from(groupData['memberFCMToken'] ?? []);

      // Determine users to add and remove
      final usersToAdd = selectedUserIds
          .where((userId) => !memberMap.containsKey(userId))
          .toList();
      final usersToRemove = widget.existingGrpMembers
          .where((userId) => !selectedUserIds.contains(userId))
          .toList();

      // Update memberMap and memberFCMTokens
      for (String userId in usersToAdd) {
        memberMap[userId] = false;
        final userData = await getUserData(userId);
        if (!memberFCMTokens.contains(userData['fcmToken'])) {
          memberFCMTokens.add(userData['fcmToken']);
        }
      }

      for (String userId in usersToRemove) {
        memberMap.remove(userId);
        final userData = await getUserData(userId);
        memberFCMTokens.remove(userData['fcmToken']);
      }

      // Update the Firestore document
      await groupDoc.update({
        'memberMap': memberMap,
        'memberFCMToken': memberFCMTokens,
      });

      showMessage("Group members updated successfully", true);
    } catch (e) {
      showMessage("Failed to update group members: $e", false);
      debugPrint('Error updating group members: $e');
    }
  }

  void handleUserSelection(String userId) {
    final selectedIds = Set<String>.from(selectedUserIds.value);
    if (selectedIds.contains(userId)) {
      selectedIds.remove(userId);
    } else {
      selectedIds.add(userId);
    }
    selectedUserIds.value = selectedIds;

    // Update newGrpMembers accordingly
    if (widget.existingGrpMembers.contains(userId)) {
      if (!selectedIds.contains(userId)) {
        newGrpMembers.remove(userId);
      }
    } else {
      if (selectedIds.contains(userId)) {
        newGrpMembers.add(userId);
      } else {
        newGrpMembers.remove(userId);
      }
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
                    "Edit Group Chat Members",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      final currentSelectedUserIds =
                          selectedUserIds.value.toSet();
                      final existingMemberIds =
                          widget.existingGrpMembers.toSet();

                      final usersToAdd =
                          currentSelectedUserIds.difference(existingMemberIds);
                      final usersToRemove =
                          existingMemberIds.difference(currentSelectedUserIds);

                      if (usersToAdd.isEmpty && usersToRemove.isEmpty) {
                        showMessage(
                            "No changes made to Group Chat Members", false);
                      } else {
                        updateGroupMembers(selectedUserIds.value.toList());
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
              ValueListenableBuilder<Set<String>>(
                valueListenable: selectedUserIds,
                builder: (context, selectedIds, child) {
                  if (selectedIds.isNotEmpty) {
                    return SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Display selected group members
                          ...selectedIds.map((userId) {
                            return FutureBuilder<Map<String, dynamic>>(
                              future: getUserData(userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else {
                                  final userData = snapshot.data!;
                                  final username =
                                      userData["username"] ?? "Unknown";
                                  final photoUrl =
                                      userData["photoURL"] ?? "Unknown";
                                  return Padding(
                                    key: Key(userId),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ProfilePicture(
                                          userId: userId,
                                          photoURL: photoUrl,
                                          radius: 22,
                                          onTap: () {},
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 75,
                                          child: Text(
                                            username,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                            overflow: TextOverflow.visible,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchUsername = value;
                  });
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search a user",
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.search,
                      color: Color.fromRGBO(247, 243, 237, 1),
                      size: 20,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(247, 243, 237, 1),
                      width: 2.5,
                    ),
                  ),
                ),
                style: Theme.of(context).textTheme.titleMedium,
                cursorColor: const Color.fromRGBO(247, 243, 237, 1),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CustomLoadingAnimation());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData &&
                        snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> allUsersList = snapshot.data!.docs;
                      allUsersList.sort((a, b) {
                        var aData = a.data() as Map<String, dynamic>;
                        var bData = b.data() as Map<String, dynamic>;
                        return aData['displayName']
                            .toString()
                            .toLowerCase()
                            .compareTo(
                                bData['displayName'].toString().toLowerCase());
                      });
                      return ListView.builder(
                        itemCount: allUsersList.length,
                        itemBuilder: (context, index) {
                          var data = allUsersList[index].data()
                              as Map<String, dynamic>;

                          if (searchUsername.isEmpty ||
                              (data['displayName'] != null &&
                                  data['displayName']
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          searchUsername.toLowerCase()))) {
                            return ValueListenableBuilder<Set<String>>(
                              valueListenable: selectedUserIds,
                              builder: (context, selectedIds, child) {
                                return UserListTile(
                                  key: Key(allUsersList[index].id),
                                  userId: allUsersList[index].id,
                                  onUserSelected: handleUserSelection,
                                  isSelected: selectedIds
                                      .contains(allUsersList[index].id),
                                );
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return const Center(child: Text('Oops! No users found!'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
