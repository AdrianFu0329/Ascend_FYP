import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:flutter/material.dart';

class EventNotificationCard extends StatelessWidget {
  final String eventId;
  final String userId;
  final String eventTitle;
  final String requestUserId;
  final List<dynamic> acceptedList;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventLocation;
  final List<dynamic> eventSport;
  final String posterURL;
  final String participants;

  const EventNotificationCard({
    super.key,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.requestUserId,
    required this.acceptedList,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventFees,
    required this.eventLocation,
    required this.eventSport,
    required this.posterURL,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle notificationTextStyle = TextStyle(
      fontSize: 14,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Theme.of(context).scaffoldBackgroundColor,
    );

    Widget buildCard() {
      return SizedBox(
        height: 75,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(
              color: Color.fromRGBO(194, 0, 0, 1),
              width: 2.0,
            ),
          ),
          color: const Color.fromRGBO(247, 243, 237, 1),
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: getUserData(requestUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomLoadingAnimation();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final userData = snapshot.data!;
                  final username = userData["username"] ?? "Unknown";
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.event,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 24,
                          ),
                          Flexible(
                            child: Text(
                              "Your Sports Event has a Request!",
                              style: notificationTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      child: buildCard(),
    );
  }
}
