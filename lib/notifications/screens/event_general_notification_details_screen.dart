import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/notifications/service/local_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventGeneralNotificationDetailsScreen extends StatefulWidget {
  final String notificationId;
  final String eventId;
  final String groupId;
  final String title;
  final String message;

  const EventGeneralNotificationDetailsScreen({
    super.key,
    required this.title,
    required this.message,
    required this.notificationId,
    required this.eventId,
    required this.groupId,
  });

  @override
  State<EventGeneralNotificationDetailsScreen> createState() =>
      _EventGeneralNotificationDetailsScreenState();
}

class _EventGeneralNotificationDetailsScreenState
    extends State<EventGeneralNotificationDetailsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showMessage(String message, {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
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

  Future<void> deleteNotification() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notification')
        .doc(widget.notificationId)
        .delete();
  }

  String fromDateToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    // Check if the timestamp is today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Return the time only in 24-hour format
      String formattedTime = DateFormat('HH:mm').format(dateTime);
      return formattedTime;
    } else {
      // Return the date and time in 24-hour format
      String formattedDateTime =
          DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
      return formattedDateTime;
    }
  }

  DateTime getDateTimeFromStrings(String date, String time) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateTime datePart = dateFormat.parse(date);
    final DateTime timePart = timeFormat.parse(time);

    // Combine the date and time parts
    return DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      timePart.hour,
      timePart.minute,
    );
  }

  Future<void> applyEventScheduleNotification() async {
    final DocumentReference events = widget.groupId != "Unknown"
        ? FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection("events")
            .doc(widget.eventId)
        : FirebaseFirestore.instance.collection("events").doc(widget.eventId);

    try {
      DocumentSnapshot eventSnapshot = await events.get();
      if (eventSnapshot.exists) {
        Map<String, dynamic> eventsData =
            eventSnapshot.data() as Map<String, dynamic>;
        final String eventDate = eventsData['date']; // e.g., 2026-06-25
        final String eventStartTime = eventsData['startTime']; // e.g., 19:30
        final String eventTitle = eventsData['title'];
        final String eventLocation = eventsData['location'];

        // Combine date and time to create a DateTime object
        DateTime eventDateTime =
            getDateTimeFromStrings(eventDate, eventStartTime);

        // Subtract one hour for the notification schedule
        DateTime scheduledTime =
            eventDateTime.subtract(const Duration(hours: 1));
        debugPrint(scheduledTime.toString());

        // Format the time for the notification
        final String formattedTime =
            fromDateToString(Timestamp.fromDate(eventDateTime));

        // Schedule Event Notification
        await NotificationService.scheduleNotification(
          0,
          "Event Participation Reminder",
          "Reminder: $eventTitle sports event at $eventLocation at $formattedTime",
          scheduledTime,
        );

        // Instant Notification to notify scheduled notification
        await NotificationService.showInstantNotification(
          1,
          "Event Participation Reminder",
          "Event reminder has been set for $eventTitle sports event at $eventLocation at $formattedTime",
        );
      } else {
        debugPrint("Group event data not found");
      }
    } catch (e) {
      debugPrint("Failed to schedule notification: $e");
    }
  }

  void onReadPress() async {
    try {
      applyEventScheduleNotification();
      // Delete Notification
      await deleteNotification();
      _showMessage("Your response and reminder has been recorded!",
          onOkPressed: () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showMessage(
          "There was an unexpected error while recording your response. Try again later!");
    }
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
              future: getPoster(generalNotification),
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
                          widget.title,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
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
                      const Color.fromRGBO(194, 0, 0, 1),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(194, 0, 0, 1),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: onReadPress,
                  child: const Text(
                    'Schedule Reminder',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Merriweather Sans',
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(247, 243, 237, 1),
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
