import 'package:ascend_fyp/community/events/screens/edit/mark_attendance_screen.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/community/events/screens/edit/edit_event_details_screen.dart';
import 'package:ascend_fyp/community/events/screens/edit/edit_event_participants_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventSettingsScreen extends StatefulWidget {
  final String eventId;
  final String groupId;
  final String eventTitle;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventSport;
  final String eventLocation;
  final String participants;
  final String posterURL;
  final List<dynamic> acceptedList;
  final List<dynamic> attendanceList;
  final bool isOther;
  final bool isGroupEvent;

  const EventSettingsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventFees,
    required this.eventSport,
    required this.eventLocation,
    required this.participants,
    required this.posterURL,
    required this.isOther,
    required this.isGroupEvent,
    required this.acceptedList,
    required this.attendanceList,
    required this.groupId,
  });

  @override
  State<EventSettingsScreen> createState() => _EventSettingsScreenState();
}

class _EventSettingsScreenState extends State<EventSettingsScreen> {
  late String eventDate;
  late String eventEndTime;
  late String eventFees;
  late String eventLocation;
  late String eventSport;
  late String eventStartTime;
  late String eventTitle;
  late String participants;
  late String posterURL;
  late List<dynamic> acceptedList;
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
    acceptedList = widget.acceptedList;
    isOther = widget.isOther;
  }

  void _showMessage(String message, bool confirm,
      {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
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
                if (confirm) {
                  if (onYesPressed != null) {
                    onYesPressed();
                  }
                } else {
                  if (onOKPressed != null) {
                    onOKPressed();
                  }
                }
              },
              child: Text(
                confirm ? 'Yes' : 'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            confirm
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Future<bool> deleteEvent() async {
    try {
      widget.isGroupEvent
          ? await FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId)
              .collection('events')
              .doc(widget.eventId)
              .delete()
          : await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .delete();

      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 50),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color.fromRGBO(247, 243, 237, 1),
            width: 1.5,
          ),
        ),
      ),
    );

    ButtonStyle deleteButtonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 50),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        Colors.red,
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Event Settings',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: PopScope(
          canPop: false,
          onPopInvoked: ((didPop) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop(
              {
                'title': eventTitle,
                'sports': eventSport,
                'fees': eventFees,
                'location': eventLocation,
                'participants': participants,
                'date': eventDate,
                'startTime': eventStartTime,
                'endTime': eventEndTime,
                'isOther': isOther,
                'posterURL': posterURL,
                'acceptedList': acceptedList,
              },
            );
          }),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color.fromRGBO(247, 243, 237, 1),
            ),
            onPressed: () {
              Navigator.of(context).pop(
                {
                  'title': eventTitle,
                  'sports': eventSport,
                  'fees': eventFees,
                  'location': eventLocation,
                  'participants': participants,
                  'date': eventDate,
                  'startTime': eventStartTime,
                  'endTime': eventEndTime,
                  'isOther': isOther,
                  'posterURL': posterURL,
                  'acceptedList': acceptedList,
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _showMessage(
              "Are you sure you would like to cancel your sports event?",
              true,
              onYesPressed: () async {
                bool isDeleted = await deleteEvent();
                if (isDeleted) {
                  _showMessage(
                    "Event cancelled successfully",
                    false,
                    onOKPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                  );
                } else {
                  _showMessage(
                      "Unable to cancel event. Try again later...", false);
                }
              },
            );
          },
          style: deleteButtonStyle,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.delete_outline_outlined,
                    size: 30,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text('Cancel Event'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final changeResult = await Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => EditEventDetailsScreen(
                        eventId: widget.eventId,
                        groupId: widget.groupId,
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
                        isGroupEvent: widget.isGroupEvent,
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
                style: buttonStyle,
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_document,
                      size: 30,
                      color: Color.fromRGBO(247, 243, 237, 1),
                    ),
                    SizedBox(width: 16),
                    Text('Edit Event Details'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final changeResult = await Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => EditEventParticipantsScreen(
                        eventId: widget.eventId,
                        groupId: widget.groupId,
                        acceptedList: widget.acceptedList,
                      ),
                    ),
                  );

                  if (changeResult != null) {
                    setState(() {
                      acceptedList = changeResult['acceptedList'];
                    });
                  }
                },
                style: buttonStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 30,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        SizedBox(width: 16),
                        Text('Edit Participants'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final changeResult = await Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => MarkAttendanceScreen(
                        eventId: widget.eventId,
                        groupId: widget.groupId,
                        acceptedList: widget.acceptedList,
                        attendanceList: widget.attendanceList,
                      ),
                    ),
                  );

                  if (changeResult != null) {
                    setState(() {
                      acceptedList = changeResult['acceptedList'];
                    });
                  }
                },
                style: buttonStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 30,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        SizedBox(width: 16),
                        Text('Mark Attendance'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
