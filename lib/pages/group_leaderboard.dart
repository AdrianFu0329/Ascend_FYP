import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/widgets/group_member_tile.dart';
import 'package:ascend_fyp/widgets/leaderboard_top_3.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupLeaderboard extends StatelessWidget {
  final String groupId;
  const GroupLeaderboard({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
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
              stream: getLeaderboardForCurrentGroup(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomLoadingAnimation();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final leaderboardDocs = snapshot.data!.docs;
                  // Extract the first three user IDs
                  final top1UserId = leaderboardDocs[0]['userId'];
                  final top2UserId = leaderboardDocs[1]['userId'];
                  final top3UserId = leaderboardDocs[2]['userId'];

                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        LeaderboardTop3(
                          top1UserId: top1UserId,
                          top2UserId: top2UserId,
                          top3UserId: top3UserId,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: leaderboardDocs.length > 3
                                ? leaderboardDocs.length - 3
                                : 0,
                            itemBuilder: (context, index) {
                              // Adjust index to skip the first three entries
                              final adjustedIndex = index + 3;
                              final leaderboardData =
                                  leaderboardDocs[adjustedIndex].data()
                                      as Map<String, dynamic>;
                              final userId = leaderboardData['userId'];
                              final participation =
                                  leaderboardData['groupEventsJoined'];

                              return FutureBuilder<Map<String, dynamic>>(
                                future: getUserData(userId),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CustomLoadingAnimation();
                                  } else if (userSnapshot.hasError) {
                                    return Center(
                                      child:
                                          Text('Error: ${userSnapshot.error}'),
                                    );
                                  } else {
                                    final userData = userSnapshot.data!;
                                    return GroupMemberTile(
                                      userId: userId,
                                      username: userData['username'],
                                      photoURL: userData['photoURL'],
                                      trailing: participation.toString(),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
