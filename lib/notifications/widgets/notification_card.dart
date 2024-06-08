import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/notifications/screens/event_notification_details_screen.dart';
import 'package:ascend_fyp/notifications/screens/general_notification_details_screen.dart';
import 'package:ascend_fyp/notifications/screens/group_notification_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final String notificationId;
  final String eventId;
  final String ownerUserId;
  final String requestUserId;
  final Timestamp timestamp;
  final String title;
  final String message;
  final String type;
  final String requestUserLocation;

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
    required this.requestUserLocation,
  });

  String fromDateToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    // Check if the timestamp is today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Return the time only
      String formattedTime = DateFormat('h:mm a').format(dateTime);
      return formattedTime;
    } else {
      // Return the date only
      String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      return formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle notificationTextStyle = const TextStyle(
      fontSize: 10,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    Icon getNotiIcon(String type) {
      Icon icon = const Icon(
        Icons.circle_notifications_sharp,
        color: Color.fromRGBO(247, 243, 237, 1),
        size: 35,
      );
      switch (type) {
        case "Events":
          icon = const Icon(
            Icons.calendar_today,
            color: Color.fromRGBO(247, 243, 237, 1),
            size: 35,
          );
        case "Groups":
          icon = const Icon(
            Icons.groups_2_rounded,
            color: Color.fromRGBO(247, 243, 237, 1),
            size: 35,
          );
      }

      return icon;
    }

    Widget buildCard() {
      String formattedTime = fromDateToString(timestamp);
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
            color: Color.fromRGBO(194, 0, 0, 1),
            width: 2.0,
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getNotiIcon(type),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: notificationTextStyle,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                formattedTime,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        switch (type) {
          case "Events":
            {
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => EventNotificationDetailsScreen(
                    notificationId: notificationId,
                    eventId: eventId,
                    ownerUserId: ownerUserId,
                    requestUserId: requestUserId,
                    timestamp: timestamp,
                    title: title,
                    message: message,
                    type: type,
                    requestUserLocation: requestUserLocation,
                  ),
                ),
              );
            }
          case "Groups":
            {
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => GroupNotificationDetailsScreen(
                    notificationId: notificationId,
                    groupId: eventId,
                    ownerUserId: ownerUserId,
                    requestUserId: requestUserId,
                    timestamp: timestamp,
                    title: title,
                    message: message,
                    type: type,
                    requestUserLocation: requestUserLocation,
                  ),
                ),
              );
            }
          case "General":
            {
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => GeneralNotificationDetailsScreen(
                    notificationId: notificationId,
                    title: title,
                    message: message,
                  ),
                ),
              );
            }
        }
      },
      child: buildCard(),
    );
  }
}
