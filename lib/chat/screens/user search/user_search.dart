import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/chat/screens/create_group_chat/create_group_chat_screen.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/chat/widgets/user_list_tile.dart';
import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  String searchUsername = "";
  TextEditingController searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  ValueNotifier<Set<String>> selectedUserIds = ValueNotifier<Set<String>>({});

  void handleUserSelection(String userId) {
    final selectedIds = Set<String>.from(selectedUserIds.value);
    if (selectedIds.contains(userId)) {
      selectedIds.remove(userId);
    } else {
      selectedIds.add(userId);
    }
    selectedUserIds.value = selectedIds;
  }

  Future<void> createChatOrGroup() async {
    if (selectedUserIds.value.length == 1) {
      String selectedUserId = selectedUserIds.value.first;
      Map<String, dynamic> userData = await getUserData(selectedUserId);
      String username = userData["username"] ?? "Unknown";
      String photoUrl = userData["photoURL"] ?? "Unknown";

      String? chatRoomId = await ChatService().createChatRoom(
        selectedUserId,
        username,
        photoUrl,
      );

      if (chatRoomId != null) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          SlidingNav(
            builder: (context) => ChatScreen(
              receiverUserId: selectedUserId,
              receiverUsername: username,
              receiverPhotoUrl: photoUrl,
              chatRoomId: chatRoomId,
              receiverFcmToken: userData["fcmToken"] ?? "Unknown",
            ),
          ),
        );
      }
    } else {
      Navigator.of(context).push(
        SlidingNav(
          builder: (context) => CreateGroupChatScreen(
            groupMemberList: selectedUserIds.value.toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          "Search User",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: selectedUserIds,
            builder: (context, selectedIds, child) {
              if (selectedIds.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Color.fromRGBO(247, 243, 237, 1),
                  ),
                  onPressed: createChatOrGroup,
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ValueListenableBuilder<Set<String>>(
              valueListenable: selectedUserIds,
              builder: (context, selectedIds, child) {
                if (selectedIds.isNotEmpty) {
                  return SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: selectedIds.map((userId) {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ProfilePicture(
                                      userId: userId,
                                      photoURL: photoUrl,
                                      radius: 27,
                                      onTap: () {},
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
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
                      }).toList(),
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
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingAnimation());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
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
                        var data =
                            allUsersList[index].data() as Map<String, dynamic>;

                        if (searchUsername.isEmpty ||
                            (data['displayName'] != null &&
                                data['displayName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchUsername.toLowerCase()))) {
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
    );
  }
}
