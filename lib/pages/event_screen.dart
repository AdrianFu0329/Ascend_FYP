import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/create_events_screen.dart';
import 'package:ascend_fyp/pages/filter_options_screen.dart';
import 'package:ascend_fyp/widgets/event_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Stream<QuerySnapshot>? eventsStream;
  Map<String, bool> filterOptions = {};

  @override
  void initState() {
    eventsStream = getEventsFromDatabase();
    super.initState();
  }

  Future<void> refreshPosts() async {
    setState(() {
      eventsStream = getEventsFromDatabase();
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

  void filterEvents() async {
    final selectedFilters = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => const FilterOptionsScreen(),
    );

    if (selectedFilters != null) {
      setState(() {
        filterOptions = selectedFilters;
        eventsStream = getFilteredEventsFromDatabase(filterOptions);
      });
    }
  }

  Stream<QuerySnapshot> getFilteredEventsFromDatabase(
      Map<String, bool> filters) {
    List<String> selectedSports = filters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSports.isEmpty) {
      return getEventsFromDatabase();
    }

    return FirebaseFirestore.instance
        .collection('events')
        .where('sports', arrayContainsAny: selectedSports)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: filterEvents,
                        icon: Row(
                          children: [
                            Text(
                              'Filter Options',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Icon(
                              Icons.filter_alt_rounded,
                              color: Color.fromRGBO(247, 243, 237, 1),
                            ),
                          ],
                        ),
                      ),
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
                    child: Text('No events found.'),
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
                          eventSport: List<String>.from(data['sports']),
                          posterURL: data['posterURL'],
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
          ),
        ],
      ),
    );
  }
}
