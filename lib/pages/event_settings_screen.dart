import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/pages/set_location_screen.dart';
import 'package:ascend_fyp/widgets/creation_sport_list.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventSettingsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventSport;
  final String eventLocation;
  final String participants;
  final String posterURL;
  final bool isOther;

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
    required this.isOther,
    required this.posterURL,
  });

  @override
  _EventSettingsScreenState createState() => _EventSettingsScreenState();
}

class _EventSettingsScreenState extends State<EventSettingsScreen> {
  late TextEditingController eventTitleController;
  late TextEditingController eventFeesController;
  late TextEditingController eventSportController;
  late TextEditingController eventLocationController;
  late TextEditingController eventParticipantsController;
  late TextEditingController eventDateController;
  late TextEditingController eventStartTimeController;
  late TextEditingController eventEndTimeController;
  late TextEditingController otherController;
  late bool isOtherEvent;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? location;
  final ValueNotifier<bool> resetNotifierSportList = ValueNotifier(false);
  final ValueNotifier<bool> resetNotifierParticipation = ValueNotifier(false);
  String? selectedSports;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    eventTitleController = TextEditingController(text: widget.eventTitle);
    eventFeesController = TextEditingController(text: widget.eventFees);
    eventSportController = TextEditingController(text: widget.eventSport);
    eventLocationController = TextEditingController(text: widget.eventLocation);
    eventParticipantsController =
        TextEditingController(text: widget.participants);
    eventDateController = TextEditingController(text: widget.eventDate);
    eventStartTimeController =
        TextEditingController(text: widget.eventStartTime);
    eventEndTimeController = TextEditingController(text: widget.eventEndTime);
    isOtherEvent = widget.isOther;
    location = widget.eventLocation;
    otherController = widget.isOther
        ? TextEditingController(text: widget.eventSport)
        : TextEditingController();
    selectedSports = widget.isOther ? "Other" : null; // Initial Sport
  }

  void _showMessage(String message) {
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

  String getPosterURL(String selectedSport) {
    String posterURL = "";
    switch (selectedSport) {
      case "Football":
        posterURL = eventFootball;
        break;
      case "Basketball":
        posterURL = eventBasketball;
        break;
      case "Badminton":
        posterURL = eventBadminton;
        break;
      case "Futsal":
        posterURL = eventFutsal;
        break;
      case "Jogging":
        posterURL = eventJogging;
        break;
      case "Gym":
        posterURL = eventGym;
        break;
      case "Tennis":
        posterURL = eventTennis;
        break;
      case "Hiking":
        posterURL = eventHiking;
        break;
      case "Cycling":
        posterURL = eventCycling;
        break;
      default:
        posterURL = eventGeneral;
        break;
    }
    return posterURL;
  }

  bool isEditButtonEnabled() {
    return eventTitleController.text.isNotEmpty ||
        eventDateController.text.isNotEmpty ||
        eventEndTimeController.text.isNotEmpty ||
        eventFeesController.text.isNotEmpty ||
        eventLocationController.text.isNotEmpty ||
        eventParticipantsController.text.isNotEmpty ||
        eventSportController.text.isNotEmpty ||
        eventStartTimeController.text.isNotEmpty ||
        eventTitleController.text.isNotEmpty;
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        eventDateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> selectStartTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        eventStartTimeController.text = picked.format(context).toString();
      });
    }
  }

  Future<void> selectEndTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        eventEndTimeController.text = picked.format(context).toString();
      });
    }
  }

  Future<void> getLocation() async {
    final Map<String, dynamic> locationData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SetLocationScreen(
          enableCurrentLocation: false,
        ),
      ),
    );
    String? city = locationData['location'];
    if (locationData.isNotEmpty) {
      setState(() {
        location = city;
      });
    } else {
      debugPrint("No location data...");
    }
  }

  Future<void> updateFields() async {
    setState(() {
      isUpdating = true;
      if (otherController.text.isNotEmpty) {
        isOtherEvent = true;
        selectedSports = otherController.text.trim();
      }
    });

    DocumentReference eventRef =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);

    try {
      await eventRef.update({
        'title': eventTitleController.text.trim(),
        'sports': selectedSports,
        'fees': eventFeesController.text.trim(),
        'location': location ?? eventLocationController.text.trim(),
        'participants': eventParticipantsController.text.trim(),
        'date': eventDateController.text.trim(),
        'startTime': eventStartTimeController.text.trim(),
        'endTime': eventEndTimeController.text.trim(),
        'isOther': isOtherEvent,
        'posterURL': getPosterURL(selectedSports!),
      });

      setState(() {
        isUpdating = false;
      });
    } catch (error) {
      setState(() {
        isUpdating = false;
      });
      _showMessage('An error occurred. Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle locationButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 14,
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
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Edit Event Details',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "Event Title",
                      controller: eventTitleController,
                      prefixIcon: const Icon(
                        Icons.calendar_month,
                        size: 30,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "No. of Participants (eg: 10)",
                      controller: eventParticipantsController,
                      prefixIcon: const Icon(
                        Icons.group,
                        size: 30,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "Fees (eg: RM 10 per pax, Free)",
                      controller: eventFeesController,
                      prefixIcon: const Icon(
                        Icons.attach_money,
                        size: 30,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300, // Adjusted height
                      child: CreationSportsList(
                        onSelectionChanged: (selected) {
                          setState(() {
                            selectedSports = selected;
                            if (selected != 'Other') {
                              isOtherEvent = false;
                              otherController.clear();
                            }
                          });
                        },
                        resetNotifier: resetNotifierSportList,
                        initialSelectedSport:
                            widget.isOther ? "Other" : widget.eventSport,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (selectedSports ==
                        'Other') // Conditionally display the text field
                      CustomTextField(
                        controller: otherController,
                        hintText: "Other (please specify)",
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: getLocation,
                        style: locationButtonStyle,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text("Change Event's Location"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: LocationListTile(
                        location: location ?? "No Location Selected",
                        onPress: null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: eventDateController,
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: Theme.of(context).textTheme.titleMedium,
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(247, 243, 237, 1),
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(247, 243, 237, 1),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        selectDate();
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextField(
                            controller: eventStartTimeController,
                            decoration: InputDecoration(
                              labelText: "Start Time",
                              labelStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              filled: true,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              prefixIcon: const Icon(
                                Icons.schedule,
                                color: Color.fromRGBO(247, 243, 237, 1),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              selectStartTime();
                            },
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            controller: eventEndTimeController,
                            decoration: InputDecoration(
                              labelText: "End Time",
                              labelStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              filled: true,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              prefixIcon: const Icon(
                                Icons.schedule,
                                color: Color.fromRGBO(247, 243, 237, 1),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(247, 243, 237, 1),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              selectEndTime();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromRGBO(194, 0, 0, 1)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(
                                color: Color.fromRGBO(194, 0, 0, 1),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if ((isEditButtonEnabled())) {
                            updateFields();
                            Navigator.of(context).pop(
                              {
                                'title': eventTitleController.text.trim(),
                                'sports': selectedSports,
                                'fees': eventFeesController.text.trim(),
                                'location': location ??
                                    eventLocationController.text.trim(),
                                'participants':
                                    eventParticipantsController.text.trim(),
                                'date': eventDateController.text.trim(),
                                'startTime':
                                    eventStartTimeController.text.trim(),
                                'endTime': eventEndTimeController.text.trim(),
                                'isOther': isOtherEvent,
                                'posterURL': getPosterURL(selectedSports!),
                              },
                            );
                          }
                        },
                        child: Text(
                          'Update Event',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
            if (isUpdating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0),
                  child: const Center(
                    child: ContainerLoadingAnimation(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
