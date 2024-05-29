import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/geolocation/Geolocation.dart';
import 'package:ascend_fyp/pages/group_details.dart';
import 'package:ascend_fyp/widgets/circle_tab_indicator.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/sliver_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String ownerUserId;
  final String groupTitle;
  final List<dynamic> requestList;
  final List<dynamic> memberList;
  final String groupSport;
  final String posterURL;
  final String participants;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.ownerUserId,
    required this.groupTitle,
    required this.requestList,
    required this.memberList,
    required this.groupSport,
    required this.posterURL,
    required this.participants,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool requestedToJoin = false;
  bool joined = false;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.requestList.contains(currentUser.uid)) {
      requestedToJoin = true;
    }
    if (widget.memberList.contains(currentUser.uid)) {
      joined = true;
    }
  }

  void _showLocationMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            "Only your current location will be shared with the event's owner. \nAre you alright with that?",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRequestPressed();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> getCurrentPosition() async {
    Position position = await GeoLocation().getLocation();

    String? address = await GeoLocation()
        .getCityFromCoordinates(position.latitude, position.longitude);

    return address ?? "Unknown";
  }

  Future<void> onRequestPressed() async {
    setState(() {
      requestedToJoin = true;
    });

    widget.requestList.add(currentUser.uid);

    final String notificationId = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ownerUserId)
        .collection('notification')
        .doc()
        .id;

    final Map<String, dynamic> notificationData = {
      'notificationId': notificationId,
      'groupId': widget.groupId,
      'ownerUserId': widget.ownerUserId,
      'title': "A request has been made to join your sports event!",
      'message':
          "${currentUser.displayName} has requested to join your sports event '${widget.groupTitle}'. You may contact the user and approve or deny his request below.",
      'requestUserId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': Timestamp.now(),
      'type': "Groups",
      'requestUserLocation': await getCurrentPosition(),
    };

    // Add the notification document to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ownerUserId)
        .collection('notification')
        .doc(notificationId)
        .set(notificationData);

    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
    groupRef.update({'requestList': widget.requestList});

    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ownerUserId)
        .collection('groups')
        .doc(widget.groupId);
    userRef.update({'requestList': widget.requestList});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle grpMemberStyle = const TextStyle(
      fontSize: 20,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    TextStyle selectedTabBarStyle = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    TextStyle unselectedTabBarStyle = const TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  joined
                      ? Colors.greenAccent
                      : (requestedToJoin
                          ? Colors.greenAccent
                          : const Color.fromRGBO(194, 0, 0, 1)),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(
                      color: joined
                          ? Colors.greenAccent
                          : (requestedToJoin
                              ? Colors.greenAccent
                              : const Color.fromRGBO(194, 0, 0, 1)),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              onPressed: joined
                  ? null
                  : (requestedToJoin ? null : _showLocationMessage),
              child: Text(
                joined
                    ? "Joined Group"
                    : (requestedToJoin
                        ? 'Already Requested'
                        : 'Request to Join'),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Merriweather Sans',
                  fontWeight: FontWeight.bold,
                  color: joined
                      ? Theme.of(context).scaffoldBackgroundColor
                      : (requestedToJoin
                          ? Theme.of(context).scaffoldBackgroundColor
                          : const Color.fromRGBO(247, 243, 237, 1)),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: FutureBuilder<Image>(
              future: getPoster(widget.posterURL),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingAnimation(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "An unexpected error occurred. Try again later...",
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: snapshot.data!.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 145,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.groupTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.75),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 190,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: Color.fromRGBO(247, 243, 237, 1),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                "Sports Involved: ${widget.groupSport}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelStyle: selectedTabBarStyle,
                    unselectedLabelStyle: unselectedTabBarStyle,
                    indicator: CircleTabIndicator(
                      color: Colors.red,
                      radius: 4,
                    ),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Leaderboard'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        GroupDetails(
                          groupId: widget.groupId,
                          memberList: widget.memberList,
                          participants: widget.participants,
                        ),
                        const Center(child: Text("Leaderboard")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
