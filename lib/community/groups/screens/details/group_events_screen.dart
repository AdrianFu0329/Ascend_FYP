import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/community/groups/screens/create/create_group_events_screen.dart';
import 'package:ascend_fyp/community/events/widgets/event_card.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupEventsScreen extends StatefulWidget {
  final String groupId;
  final String groupSport;
  final List<dynamic> groupMembers;
  final String groupName;
  const GroupEventsScreen({
    super.key,
    required this.groupId,
    required this.groupSport,
    required this.groupMembers,
    required this.groupName,
  });

  @override
  State<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends State<GroupEventsScreen> {
  Stream<QuerySnapshot>? eventsStream;
  Map<String, bool> filterOptions = {};

  @override
  void initState() {
    deleteOutdatedEvents();
    eventsStream = getGroupEventsFromDatabase(widget.groupId);
    super.initState();
  }

  Future<void> deleteOutdatedEvents() async {
    try {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Reference to the events collection
      CollectionReference eventsRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('events');

      // Get all events
      QuerySnapshot snapshot = await eventsRef.get();

      // Batch for deleting documents
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Iterate through each event document
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Parse event date and time
        DateTime eventDate = DateTime.parse(data['date'] as String);

        // Parse event end time with AM/PM consideration
        final timeString = data['endTime'] as String;
        final timeParts = timeString.split(":");
        int hour = int.parse(timeParts[0]);
        int minute =
            int.parse(timeParts[1].substring(0, 2)); // get first two characters

        // Check for AM/PM and adjust hour accordingly
        if (timeString.contains("PM") && hour != 12) {
          hour += 12;
        } else if (timeString.contains("AM") && hour == 12) {
          hour = 0;
        }
        DateTime eventEndTime = DateTime(
            eventDate.year, eventDate.month, eventDate.day, hour, minute);

        // Combine event date and time to create DateTime object
        DateTime eventDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          eventEndTime.hour,
          eventEndTime.minute,
        );

        // Check if the event is outdated
        if (eventDateTime.isBefore(now)) {
          // Add the event document to the batch for deletion
          batch.delete(doc.reference);
        }
      }

      // Commit the batch
      await batch.commit();

      debugPrint('Outdated events deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting outdated events: $e');
    }
  }

  Future<void> refreshPosts() async {
    setState(() {
      eventsStream = getGroupEventsFromDatabase(widget.groupId);
    });
  }

  void modalBottomSheet(Widget screen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => screen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          modalBottomSheet(CreateGroupEventsScreen(
                            groupId: widget.groupId,
                            groupSport: widget.groupSport,
                            groupMembers: widget.groupMembers,
                            groupName: widget.groupName,
                          ));
                        },
                        icon: const Icon(Icons.add),
                        color: Colors.red,
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: eventsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CustomLoadingAnimation(),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text('No Group Events Found.'),
                  ),
                );
              } else if (snapshot.hasData) {
                List<DocumentSnapshot> eventsList = snapshot.data!.docs;
                return FutureBuilder<List<DocumentSnapshot>>(
                  future: sortEventsByDistance(eventsList),
                  builder: (context, sortedSnapshot) {
                    if (sortedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CustomLoadingAnimation(),
                        ),
                      );
                    } else if (sortedSnapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text('Error: ${sortedSnapshot.error}'),
                        ),
                      );
                    } else if (sortedSnapshot.hasData) {
                      List<DocumentSnapshot> sortedEventsList =
                          sortedSnapshot.data!;
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            DocumentSnapshot doc = sortedEventsList[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: EventCard(
                                eventId: data['eventId'],
                                groupId: widget.groupId,
                                userId: data['userId'],
                                eventTitle: data['title'],
                                requestList:
                                    List<String>.from(data['requestList']),
                                acceptedList:
                                    List<String>.from(data['acceptedList']),
                                attendanceList:
                                    List<String>.from(data['attendanceList']),
                                eventDate: data['date'],
                                eventStartTime: data['startTime'],
                                eventEndTime: data['endTime'],
                                eventFees: data['fees'],
                                eventLocation: data['location'],
                                eventSport: data['sports'],
                                posterURL: data['posterURL'],
                                participants: data['participants'],
                                isOther: data['isOther'],
                                isGroupEvent: true,
                              ),
                            );
                          },
                          childCount: eventsList.length,
                        ),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            Center(
                              child: Text('No events at the moment!'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      Center(
                        child: Text('No group events at the moment!'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
