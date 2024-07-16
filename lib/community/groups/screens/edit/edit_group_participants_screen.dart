import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/user_details_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditGroupParticipantsScreen extends StatefulWidget {
  final String groupId;
  final List<dynamic> memberList;

  const EditGroupParticipantsScreen({
    super.key,
    required this.groupId,
    required this.memberList,
  });

  @override
  State<EditGroupParticipantsScreen> createState() =>
      _EditGroupParticipantsScreenState();
}

class _EditGroupParticipantsScreenState
    extends State<EditGroupParticipantsScreen> {
  late List<dynamic> memberList;
  bool isUpdating = false;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    memberList = List.from(widget.memberList);
    memberList.remove(currentUser.uid);
  }

  void _showMessage(String message, bool confirm,
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

  Future<void> updateFields(String userId) async {
    setState(() {
      isUpdating = true;
    });

    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    try {
      await groupRef.update({
        'memberList': memberList,
      });

      //Delete leaderboard data
      await groupRef.collection('leaderboard').doc(userId).delete();

      setState(() {
        isUpdating = false;
      });
      _showMessage('Group participants updated successfully!', false);
    } catch (error) {
      setState(() {
        isUpdating = false;
      });
      _showMessage(
          'An error occurred. Failed to update group participants: $error',
          false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Group Participants',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: PopScope(
          canPop: false,
          onPopInvoked: ((didPop) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop(
              {
                'memberList': memberList,
              },
            );
          }),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            onPressed: () {
              Navigator.of(context).pop(
                {
                  'memberList': memberList,
                },
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: getMembersForGroup(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CustomLoadingAnimation());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No members found.'));
                }

                final List<dynamic> membersList = snapshot.data!['memberList'];
                membersList.remove(currentUser.uid);

                if (membersList.isEmpty) {
                  return const Center(
                      child: Text('No members in this group yet.'));
                }

                return ListView.builder(
                  itemCount: membersList.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(membersList[index]),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CustomLoadingAnimation();
                        } else if (userSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${userSnapshot.error}'),
                          );
                        } else if (!userSnapshot.hasData) {
                          return const Center(
                              child: Text('User data not found.'));
                        }
                        final userId = membersList[index];
                        final userData = userSnapshot.data!;
                        return UserDetailsTile(
                          userId: userId,
                          username: userData['username'],
                          photoURL: userData['photoURL'],
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _showMessage(
                                  "Are you sure you want to remove ${userData['username']} from your group?",
                                  true, onYesPressed: () {
                                setState(() {
                                  membersList.remove(userId);
                                  membersList.insert(0, currentUser.uid);
                                  memberList = membersList;
                                });
                                updateFields(userId);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (isUpdating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0),
                child: const Center(
                  child: CustomLoadingAnimation(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
