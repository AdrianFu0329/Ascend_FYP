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
    deleteOutdatedEvents();
    eventsStream = getEventsFromDatabase();
    super.initState();
  }

  Future<void> deleteOutdatedEvents() async {
    try {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Reference to the events collection
      CollectionReference eventsRef =
          FirebaseFirestore.instance.collection('events');

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

    List<String> excludedSports = [
      'Football',
      'Basketball',
      'Tennis',
      'Gym',
      'Jogging',
      'Hiking',
      'Futsal',
      'Badminton',
      'Cycling'
    ];

    if (selectedSports.isEmpty) {
      return getEventsFromDatabase();
    } else if (selectedSports.contains('Other') && selectedSports.length > 1) {
      excludedSports.removeWhere((sport) => selectedSports.contains(sport));
      return FirebaseFirestore.instance
          .collection('events')
          .where('sports', isNotEqualTo: excludedSports)
          .snapshots();
    } else if (selectedSports.contains('Other') && selectedSports.length == 1) {
      return FirebaseFirestore.instance
          .collection('events')
          .where('isOther', isEqualTo: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('events')
          .where('sports', arrayContainsAny: selectedSports)
          .snapshots();
    }
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
                    child: Text('No Events Found.'),
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
