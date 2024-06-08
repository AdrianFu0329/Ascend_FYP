import 'package:ascend_fyp/chat/chat_service.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/user_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({
    super.key,
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  String searchUsername = "";
  TextEditingController searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                    return const Center(
                      child: CustomLoadingAnimation(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No users found.'),
                    );
                  } else if (snapshot.hasData) {
                    List<DocumentSnapshot> allUsersList = snapshot.data!.docs;
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
                                    .contains(
                                      searchUsername.toLowerCase(),
                                    ))) {
                          return UserListTile(
                            onPress: (selectedUserId, selectedUsername,
                                selectedPhotoUrl) {
                              setState(() {
                                ChatService().createChatRoom(
                                  selectedUserId,
                                  selectedUsername,
                                  selectedPhotoUrl,
                                  context,
                                );
                              });
                            },
                            userId: allUsersList[index].id,
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Oops! No users found!'),
                    );
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
