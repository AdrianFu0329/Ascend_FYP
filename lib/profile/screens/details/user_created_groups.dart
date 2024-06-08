import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/groups/widgets/group_card.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUserCreatedGroups extends StatefulWidget {
  const CurrentUserCreatedGroups({super.key});

  @override
  State<CurrentUserCreatedGroups> createState() =>
      _CurrentUserCreatedGroupsState();
}

class _CurrentUserCreatedGroupsState extends State<CurrentUserCreatedGroups> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<QuerySnapshot>(
      stream: getGroupsFromDatabase(),
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
            child: Text('No events found.'),
          );
        } else if (snapshot.hasData) {
          List<DocumentSnapshot> allEventsList = snapshot.data!.docs;

          // Filter events where current user's UID is in acceptedList
          List<DocumentSnapshot> filteredEventsList =
              allEventsList.where((doc) {
            String ownerUserId = doc['ownerUserId'];
            return ownerUserId.contains(currentUser.uid);
          }).toList();

          if (filteredEventsList.isEmpty) {
            return const Center(
              child: Text(
                'You have not created any community groups at the moment!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredEventsList.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = filteredEventsList[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GroupCard(
                  groupId: data['groupId'],
                  ownerUserId: data['ownerUserId'],
                  groupTitle: data['name'],
                  requestList: List<dynamic>.from(data['requestList']),
                  memberList: List<dynamic>.from(data['memberList']),
                  groupSport: data['sports'],
                  posterURL: data['posterURL'],
                  participants: data['participants'],
                  isOther: data['isOther'],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text(
                'You have not created any community groups at the moment!'),
          );
        }
      },
    );
  }
}
