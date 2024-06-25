import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/user_details_tile.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;
  final List<dynamic> memberList;
  final int participants;

  const GroupDetails({
    super.key,
    required this.groupId,
    required this.memberList,
    required this.participants,
  });

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  @override
  Widget build(BuildContext context) {
    TextStyle grpMemberStyle = const TextStyle(
      fontSize: 20,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.groups_2_rounded,
                  color: Color.fromRGBO(247, 243, 237, 1),
                ),
                const SizedBox(width: 12),
                Text(
                  "${widget.memberList.length} / ${widget.participants}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Group Members: ",
              style: grpMemberStyle,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: getMembersForCurrentGroup(widget.groupId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingAnimation();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final leaderboardDocs = snapshot.data!.docs;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: leaderboardDocs.length,
                        itemBuilder: (context, index) {
                          final leaderboardData = leaderboardDocs[index].data()
                              as Map<String, dynamic>;
                          final userId = leaderboardData['userId'];
                          final role = leaderboardData['role'];

                          return FutureBuilder<Map<String, dynamic>>(
                            future: getUserData(userId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CustomLoadingAnimation();
                              } else if (userSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${userSnapshot.error}'),
                                );
                              } else {
                                final userData = userSnapshot.data!;
                                return UserDetailsTile(
                                  userId: userId,
                                  username: userData['username'],
                                  photoURL: userData['photoURL'],
                                  trailing: Text(
                                    role,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
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
