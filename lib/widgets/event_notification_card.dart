import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/event_notification_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String notificationId;
  final String eventId;
  final String ownerUserId;
  final String requestUserId;
  final Timestamp timestamp;
  final String title;
  final String message;
  final String type;

  const NotificationCard({
    super.key,
    required this.notificationId,
    required this.ownerUserId,
    required this.timestamp,
    required this.title,
    required this.message,
    required this.eventId,
    required this.requestUserId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle notificationTextStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Theme.of(context).scaffoldBackgroundColor,
    );

    Icon getNotiIcon(String type) {
      Icon icon = Icon(
        Icons.circle_notifications_sharp,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 24,
      );
      switch (type) {
        case "Events":
          icon = Icon(
            Icons.calendar_today,
            color: Theme.of(context).scaffoldBackgroundColor,
            size: 24,
          );
        // Other different types of notification icons here
      }

      return icon;
    }

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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getNotiIcon(type),
                    Flexible(
                      child: Text(
                        title,
                        style: notificationTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlidingNav(
            builder: (context) => NotificationDetailsScreen(
              notificationId: notificationId,
              eventId: eventId,
              ownerUserId: ownerUserId,
              requestUserId: requestUserId,
              timestamp: timestamp,
              title: title,
              message: message,
              type: type,
            ),
          ),
        );
      },
      child: buildCard(),
    );
  }
}
