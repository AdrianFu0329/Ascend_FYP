import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/community/events/screens/create/create_events_screen.dart';
import 'package:ascend_fyp/general%20pages/filter_options_screen.dart';
import 'package:ascend_fyp/community/events/widgets/event_card.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Future<List<DocumentSnapshot>>? eventsFuture;
  Map<String, bool> filterOptions = {};
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    deleteOutdatedEvents();
    getCurrentLocation().then((position) {
      setState(() {
        currentPosition = position;
        eventsFuture = fetchAndSortEvents();
      });
    });
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> deleteOutdatedEvents() async {
    try {
      DateTime now = DateTime.now();
      CollectionReference eventsRef =
          FirebaseFirestore.instance.collection('events');
      QuerySnapshot snapshot = await eventsRef.get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime eventDate = DateTime.parse(data['date'] as String);
        final timeString = data['endTime'] as String;
        final timeParts = timeString.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1].substring(0, 2));

        if (timeString.contains("PM") && hour != 12) {
          hour += 12;
        } else if (timeString.contains("AM") && hour == 12) {
          hour = 0;
        }
        DateTime eventEndTime = DateTime(
            eventDate.year, eventDate.month, eventDate.day, hour, minute);
        DateTime eventDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          eventEndTime.hour,
          eventEndTime.minute,
        );

        if (eventDateTime.isBefore(now)) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
      debugPrint('Outdated events deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting outdated events: $e');
    }
  }

  Future<List<DocumentSnapshot>> fetchAndSortEvents() async {
    var eventsSnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    var eventsList = eventsSnapshot.docs;
    return sortEventsByDistance(eventsList);
  }

  void refreshEvents() {
    setState(() {
      eventsFuture = fetchAndSortEvents();
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
        eventsFuture = fetchAndSortEvents();
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
    return RefreshIndicator(
      onRefresh: () async {
        refreshEvents();
      },
      backgroundColor: Theme.of(context).cardColor,
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingAnimation(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Events Found.'),
                  );
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> sortedEventsList = snapshot.data!;
                  return ListView.builder(
                    itemCount: sortedEventsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = sortedEventsList[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: EventCard(
                          eventId: data['eventId'],
                          groupId: data['isGroupEvent']
                              ? data['groupId']
                              : "Unknown",
                          userId: data['userId'],
                          eventTitle: data['title'],
                          requestList: List<String>.from(data['requestList']),
                          acceptedList: List<String>.from(data['acceptedList']),
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
                          isGroupEvent: data['isGroupEvent'],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No events at the moment!'),
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
