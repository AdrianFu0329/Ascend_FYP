import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/create_events_screen.dart';
import 'package:ascend_fyp/widgets/event_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupEventsScreen extends StatefulWidget {
  final String groupId;
  const GroupEventsScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends State<GroupEventsScreen> {
  Stream<QuerySnapshot>? eventsStream;
  Map<String, bool> filterOptions = {};

  @override
  void initState() {
    eventsStream = getGroupEventsFromDatabase(widget.groupId);
    super.initState();
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
                          modalBottomSheet(const CreateEventsScreen());
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
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      DocumentSnapshot doc = eventsList[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

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
                    childCount: eventsList.length,
                  ),
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
