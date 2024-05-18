import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/create_events_screen.dart';
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
  late String eventId;
  late String userId;
  late String eventTitle;
  late String eventDate;
  late List<String> eventSport;
  late String eventStartTime;
  late String eventEndTime;
  late String eventLocation;
  late String eventFees;
  late String eventParticipants;
  late List<dynamic> requestList;
  late List<dynamic> acceptedList;
  late String posterURL;

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

  void _createEventPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => const CreateEventsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textBoxStyle = const TextStyle(
      color: Color.fromRGBO(192, 192, 192, 1),
      fontSize: 14,
    );

    OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color.fromRGBO(192, 192, 192, 1),
        width: 2,
      ),
    );

    OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color.fromRGBO(192, 192, 192, 1),
        width: 2.5,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      style: textBoxStyle,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: textBoxStyle,
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromRGBO(192, 192, 192, 1)),
                        filled: true,
                        fillColor: const Color.fromRGBO(20, 23, 26, 1),
                        border: normalBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Options',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                        onPressed: _createEventPressed,
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
                      eventId = data['eventId'];
                      userId = data['userId'];
                      eventTitle = data['title'];
                      requestList = List<String>.from(data['requestList']);
                      acceptedList = List<String>.from(data['acceptedList']);
                      eventDate = data['date'];
                      eventStartTime = data['startTime'];
                      eventEndTime = data['endTime'];
                      eventFees = data["fees"];
                      eventSport = List<String>.from(data['sports']);
                      eventLocation = data['location'];
                      posterURL = data['posterURL'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: EventCard(
                          eventId: eventId,
                          userId: userId,
                          eventTitle: eventTitle,
                          requestList: requestList,
                          acceptedList: acceptedList,
                          eventDate: eventDate,
                          eventStartTime: eventStartTime,
                          eventEndTime: eventEndTime,
                          eventFees: eventFees,
                          eventLocation: eventLocation,
                          eventSport: eventSport,
                          posterURL: posterURL,
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
