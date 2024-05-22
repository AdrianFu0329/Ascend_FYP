import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/event_notification_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsNotification extends StatelessWidget {
  const EventsNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

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
        initialChildSize: 0.6,
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
                    "Notifications",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getEventsForCurrentUser(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CustomLoadingAnimation(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> eventsList =
                          snapshot.data!.docs.where((doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        return data['requestList'] != null;
                      }).toList();

                      if (eventsList.isEmpty) {
                        return const Center(
                          child: Text('No notifications at the moment!'),
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: eventsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot doc = eventsList[index];
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          List<String> requestList =
                              List<String>.from(data['requestList']);

                          return Column(
                            children: requestList
                                .map((userId) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: EventNotificationCard(
                                        eventId: data['eventId'],
                                        userId: userId,
                                        eventTitle: data['title'],
                                        requestUserId: userId,
                                        acceptedList: List<String>.from(
                                            data['acceptedList']),
                                        eventDate: data['date'],
                                        eventStartTime: data['startTime'],
                                        eventEndTime: data['endTime'],
                                        eventFees: data['fees'],
                                        eventLocation: data['location'],
                                        eventSport:
                                            List<String>.from(data['sports']),
                                        posterURL: data['posterURL'],
                                        participants: data['participants'],
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No notifications at the moment!'),
                      );
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
