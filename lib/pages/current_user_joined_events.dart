import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/event_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUserJoinedEvents extends StatefulWidget {
  const CurrentUserJoinedEvents({Key? key}) : super(key: key);

  @override
  State<CurrentUserJoinedEvents> createState() =>
      _CurrentUserJoinedEventsState();
}

class _CurrentUserJoinedEventsState extends State<CurrentUserJoinedEvents> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<QuerySnapshot>(
      stream: getEventsFromDatabase(),
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
            List<dynamic> acceptedList = doc['acceptedList'];
            return acceptedList.contains(currentUser.uid);
          }).toList();

          if (filteredEventsList.isEmpty) {
            return const Center(
              child: Text('You have not joined any events at the moment!'),
            );
          }

          return ListView.builder(
            itemCount: filteredEventsList.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = filteredEventsList[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EventCard(
                  eventId: data['eventId'],
                  userId: data['userId'],
                  eventTitle: data['title'],
                  requestList: List<String>.from(data['requestList']),
                  acceptedList: List<String>.from(data['acceptedList']),
                  eventDate: data['date'],
                  eventStartTime: data['startTime'],
                  eventEndTime: data['endTime'],
                  eventFees: data['fees'],
                  eventLocation: data['location'],
                  eventSport: data['sports'],
                  posterURL: data['posterURL'],
                  participants: data['participants'],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text('You have not joined any events at the moment!'),
          );
        }
      },
    );
  }
}
