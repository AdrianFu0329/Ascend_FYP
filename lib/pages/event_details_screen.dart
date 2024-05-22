import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final List<dynamic> eventSport;
  final String eventLocation;
  final String posterURL;
  final String participants;

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
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool requestedToJoin = false;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    if (widget.requestList.contains(currentUser.uid)) {
      requestedToJoin = true;
    }
  }

  Future<void> onRequestPressed() async {
    setState(() {
      requestedToJoin = true;
    });

    widget.requestList.add(currentUser.uid);

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
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: FutureBuilder<Image>(
              future: getEventPoster(widget.posterURL),
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
                          widget.eventTitle,
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
                                "Sports Involved: ${widget.eventSport.join(', ')}",
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
              child: SingleChildScrollView(
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
                              widget.eventDate,
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
                              "${widget.eventStartTime} - ${widget.eventEndTime}",
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
                            widget.eventLocation,
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
                          widget.eventFees,
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
                          "${widget.acceptedList.length} / ${widget.participants}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
                      requestedToJoin
                          ? Colors.greenAccent
                          : const Color.fromRGBO(194, 0, 0, 1),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: requestedToJoin
                              ? Colors.greenAccent
                              : const Color.fromRGBO(194, 0, 0, 1),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: requestedToJoin ? null : onRequestPressed,
                  child: Text(
                    requestedToJoin ? 'Already Requested' : 'Request to Join',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Merriweather Sans',
                      fontWeight: FontWeight.bold,
                      color: requestedToJoin
                          ? Theme.of(context).scaffoldBackgroundColor
                          : const Color.fromRGBO(247, 243, 237, 1),
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
}
