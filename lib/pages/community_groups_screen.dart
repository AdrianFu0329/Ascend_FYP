import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/pages/create_groups_screen.dart';
import 'package:ascend_fyp/pages/filter_options_screen.dart';
import 'package:ascend_fyp/widgets/event_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityGroupsScreen extends StatefulWidget {
  const CommunityGroupsScreen({super.key});

  @override
  State<CommunityGroupsScreen> createState() => _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends State<CommunityGroupsScreen> {
  Stream<QuerySnapshot>? groupsStream;
  Map<String, bool> filterOptions = {};

  @override
  void initState() {
    groupsStream = getGroupsFromDatabase();
    super.initState();
  }

  Future<void> refreshPosts() async {
    setState(() {
      groupsStream = getGroupsFromDatabase();
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

  void filterGroups() async {
    final selectedFilters = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => const FilterOptionsScreen(),
    );

    if (selectedFilters != null) {
      setState(() {
        filterOptions = selectedFilters;
        groupsStream = getFilteredGroupsFromDatabase(filterOptions);
      });
    }
  }

  Stream<QuerySnapshot> getFilteredGroupsFromDatabase(
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
      return getGroupsFromDatabase(); //Change Function
    } else if (selectedSports.contains('Other') && selectedSports.length > 1) {
      excludedSports.removeWhere((sport) => selectedSports.contains(sport));
      return FirebaseFirestore.instance
          .collection('groups')
          .where('sports', isNotEqualTo: excludedSports)
          .snapshots();
    } else if (selectedSports.contains('Other') && selectedSports.length == 1) {
      return FirebaseFirestore.instance
          .collection('groups')
          .where('isOther', isEqualTo: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('groups')
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
                        onPressed: filterGroups,
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
                          modalBottomSheet(const CreateGroupsScreen());
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
            stream: groupsStream,
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
                    child: Text('No Groups Found.'),
                  ),
                );
              } else if (snapshot.hasData) {
                List<DocumentSnapshot> groupsList = snapshot.data!.docs;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      DocumentSnapshot doc = groupsList[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: EventCard(
                          //Change to Group Card
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
                    childCount: groupsList.length,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      Center(
                        child: Text('No groups at the moment!'),
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