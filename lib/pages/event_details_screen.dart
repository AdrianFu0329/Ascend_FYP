import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/geolocation/Geolocation.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/event_settings_screen.dart';
import 'package:ascend_fyp/pages/user_profile_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String userId;
  final String eventTitle;
  final List<dynamic> requestList;
  final List<dynamic> acceptedList;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventSport;
  final String eventLocation;
  final String posterURL;
  final String participants;
  final bool isOther;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.requestList,
    required this.acceptedList,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventFees,
    required this.eventSport,
    required this.eventLocation,
    required this.posterURL,
    required this.participants,
    required this.isOther,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool requestedToJoin = false;
  bool joined = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String eventDate;
  late String eventEndTime;
  late String eventFees;
  late String eventLocation;
  late String eventSport;
  late String eventStartTime;
  late String eventTitle;
  late String participants;
  late String posterURL;
  late bool isOther;

  @override
  void initState() {
    super.initState();
    eventDate = widget.eventDate;
    eventEndTime = widget.eventEndTime;
    eventFees = widget.eventFees;
    eventLocation = widget.eventLocation;
    eventSport = widget.eventSport;
    eventStartTime = widget.eventStartTime;
    eventTitle = widget.eventTitle;
    participants = widget.participants;
    posterURL = widget.posterURL;
    isOther = widget.isOther;
    if (widget.requestList.contains(currentUser.uid)) {
      requestedToJoin = true;
    }

    if (widget.acceptedList.contains(currentUser.uid)) {
      joined = true;
    }
  }

  Future<void> reloadEventDetails() async {
    // Fetch the updated event details from Firestore
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();

    // Update the state variables with the new values
    setState(() {
      eventDate = eventSnapshot['date'];
      eventEndTime = eventSnapshot['endTime'];
      eventFees = eventSnapshot['fees'];
      eventLocation = eventSnapshot['location'];
      eventSport = eventSnapshot['sport'];
      eventStartTime = eventSnapshot['startTime'];
      eventTitle = eventSnapshot['title'];
      participants = eventSnapshot['participants'];
      posterURL = eventSnapshot['posterURL'];
      isOther = eventSnapshot['isOther'];
      requestedToJoin = eventSnapshot['requestList'].contains(currentUser.uid);
      joined = eventSnapshot['acceptedList'].contains(currentUser.uid);
    });
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
        .doc(widget.userId)
        .collection('notification')
        .doc()
        .id;

    final Map<String, dynamic> notificationData = {
      'notificationId': notificationId,
      'eventId': widget.eventId,
      'ownerUserId': widget.userId,
      'title': "A request has been made to join your sports event!",
      'message':
          "${currentUser.displayName} has requested to join your sports event '${widget.eventTitle}'. You may contact the user and approve or deny his request below.",
      'requestUserId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': Timestamp.now(),
      'type': "Events",
      'requestUserLocation': await getCurrentPosition(),
    };

    // Add the notification document to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notification')
        .doc(notificationId)
        .set(notificationData);

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);
    postRef.update({'requestList': widget.requestList});

    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('events')
        .doc(widget.eventId);
    userRef.update({'requestList': widget.requestList});
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = currentUser.uid == widget.userId;
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";
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
              title: Row(
                children: [
                  ProfilePicture(
                    userId: widget.userId,
                    photoURL: photoUrl,
                    radius: 15,
                    onTap: () {
                      Navigator.of(context).push(
                        SlidingNav(
                          builder: (context) => UserProfileScreen(
                              userId: widget.userId,
                              isCurrentUser: isCurrentUser),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        SlidingNav(
                          builder: (context) => UserProfileScreen(
                              userId: widget.userId,
                              isCurrentUser: isCurrentUser),
                        ),
                      );
                    },
                    child: Text(
                      username,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              actions: [
                currentUser.uid == widget.userId
                    ? IconButton(
                        onPressed: () async {
                          final changeResult = await Navigator.of(context).push(
                            SlidingNav(
                              builder: (context) => EventSettingsScreen(
                                eventId: widget.eventId,
                                eventDate: widget.eventDate,
                                eventEndTime: widget.eventEndTime,
                                eventFees: widget.eventFees,
                                eventLocation: widget.eventLocation,
                                eventSport: widget.eventSport,
                                eventStartTime: widget.eventStartTime,
                                eventTitle: widget.eventTitle,
                                participants: widget.participants,
                                posterURL: widget.posterURL,
                                isOther: widget.isOther,
                              ),
                            ),
                          );

                          if (changeResult != null) {
                            setState(() {
                              eventEndTime = changeResult['endTime'];
                              eventFees = changeResult['fees'];
                              eventLocation = changeResult['location'];
                              eventSport = changeResult['sports'];
                              eventStartTime = changeResult['startTime'];
                              eventTitle = changeResult['title'];
                              participants = changeResult['participants'];
                              posterURL = changeResult['posterURL'];
                              eventDate = changeResult['date'];
                              isOther = changeResult['isOther'];
                            });
                          }
                        },
                        icon: const Icon(Icons.settings),
                        color: const Color.fromRGBO(247, 243, 237, 1),
                      )
                    : Container(),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder<Image>(
                    future: getPoster(posterURL),
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
                                eventTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
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
                                      "Sports Involved: $eventSport",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  eventDate,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "$eventStartTime - $eventEndTime",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color.fromRGBO(247, 243, 237, 1),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                eventLocation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              color: Color.fromRGBO(247, 243, 237, 1),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              eventFees,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.groups_2_rounded,
                              color: Color.fromRGBO(247, 243, 237, 1),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${widget.acceptedList.length} / $participants",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            joined
                                ? Colors.greenAccent
                                : (requestedToJoin
                                    ? Colors.greenAccent
                                    : const Color.fromRGBO(194, 0, 0, 1)),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
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
                              ? "Joined Event"
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
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
