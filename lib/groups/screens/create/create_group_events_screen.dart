import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/pages/set_location_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';

class CreateGroupEventsScreen extends StatefulWidget {
  final String groupId;
  final String groupSport;
  const CreateGroupEventsScreen({
    super.key,
    required this.groupId,
    required this.groupSport,
  });

  @override
  State<CreateGroupEventsScreen> createState() =>
      _CreateGroupEventsScreenState();
}

class _CreateGroupEventsScreenState extends State<CreateGroupEventsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController participantsController = TextEditingController();
  TextEditingController feesController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  Map<String, dynamic> _locationData = {};
  String? location;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isCreating = false;
  bool ownerParticipation = false;
  bool isOther = false;
  final ValueNotifier<bool> resetNotifierParticipation = ValueNotifier(false);

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

    bool validateEvent() {
      if (titleController.text.trim().isEmpty) {
        _showMessage('Please enter a title.');
        return false;
      }

      if (participantsController.text.trim().isEmpty) {
        _showMessage('Please enter a participant count.');
        return false;
      }

      if (feesController.text.trim().isEmpty) {
        _showMessage('Please enter a fee amount for each participant.');
        return false;
      }

      if (dateController.text.trim().isEmpty) {
        _showMessage('Please enter the date of the event.');
        return false;
      }

      if (startTimeController.text.trim().isEmpty) {
        _showMessage('Please enter a start time for the event.');
        return false;
      }

      if (endTimeController.text.trim().isEmpty) {
        _showMessage('Please enter an end time for the event.');
        return false;
      }

      if (_locationData.isEmpty) {
        _showMessage('Please set a location.');
        return false;
      }

      return true;
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
          dateController.text = picked.toString().split(" ")[0];
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
          startTimeController.text = picked.format(context).toString();
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
          endTimeController.text = picked.format(context).toString();
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
        _locationData = locationData;
        location = city;
        setState(() {});
      } else {
        debugPrint("No location data...");
      }
    }

    String getPosterURL(String sport) {
      String posterURL = "";
      switch (sport) {
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
          isOther = true;
          break;
      }
      return posterURL;
    }

    Future<void> createEvent() async {
      if (validateEvent()) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        String location = _locationData['location'] ?? "Unknown";

        if (_formKey.currentState!.validate()) {
          setState(() {
            isCreating = true;
          });

          try {
            final String eventId =
                FirebaseFirestore.instance.collection('events').doc().id;
            List<String> acceptedList = [];
            if (ownerParticipation == false) {
              acceptedList = [];
            } else {
              acceptedList.add(currentUser.uid);
            }

            final Map<String, dynamic> eventData = {
              'eventId': eventId,
              'title': titleController.text.trim(),
              'participants': participantsController.text.trim(),
              'fees': feesController.text.trim(),
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'date': dateController.text.trim(),
              'startTime': startTimeController.text.trim(),
              'endTime': endTimeController.text.trim(),
              'location': location,
              'sports': widget.groupSport,
              'timestamp': Timestamp.now(),
              'posterURL': getPosterURL(widget.groupSport),
              'requestList': [],
              'acceptedList': acceptedList,
              'isOther': isOther,
            };

            // Add the event document to Firestore
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('events')
                .doc(eventId)
                .set(eventData);

            _showMessage('Event created successfully');

            titleController.clear();
            participantsController.clear();
            feesController.clear();
            _locationData.clear();
            dateController.clear();
            startTimeController.clear();
            endTimeController.clear();
            otherController.clear();
            setState(() {
              isCreating = false;
            });
            resetNotifierParticipation.value =
                !resetNotifierParticipation.value;
          } catch (error) {
            _showMessage('Error creating event: $error');
            setState(() {
              isCreating = false;
            });
          }
        }
      }
    }

    Widget makeDismissible({required Widget child}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: child,
          ),
        );

    return makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.25,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  controller: controller,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Create ${widget.groupSport} Event",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "Event Title",
                      controller: titleController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "No. of Participants (eg: 10)",
                      controller: participantsController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "Fees (eg: RM 10 per pax, Free)",
                      controller: feesController,
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<bool>(
                      valueListenable: resetNotifierParticipation,
                      builder: (context, reset, child) {
                        if (reset) {
                          ownerParticipation = false;
                        }
                        return CheckboxListTile(
                          title: Text(
                            "I am participating in this event",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          value: ownerParticipation,
                          onChanged: (bool? value) {
                            setState(() {
                              ownerParticipation = value ?? false;
                            });
                          },
                        );
                      },
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
                            Text("Set Event's Location"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: LocationListTile(
                        location: _locationData.isNotEmpty
                            ? location!
                            : "No Location Selected",
                        onPress: null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: TextField(
                        controller: dateController,
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
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextField(
                            controller: startTimeController,
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
                            controller: endTimeController,
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
                    const SizedBox(height: 24),
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
                          if (validateEvent()) {
                            createEvent();
                          }
                        },
                        child: Text(
                          'Create',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCreating)
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
      ),
    );
  }
}
