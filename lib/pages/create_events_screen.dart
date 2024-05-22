import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/pages/set_location_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:ascend_fyp/widgets/sport_list.dart';

class CreateEventsScreen extends StatefulWidget {
  const CreateEventsScreen({super.key});

  @override
  State<CreateEventsScreen> createState() => _CreateEventsScreenState();
}

class _CreateEventsScreenState extends State<CreateEventsScreen> {
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
  Map<String, bool> selectedSports = {};
  bool isCreating = false;

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
      List<String> sports = [];
      selectedSports.forEach((sport, isSelected) {
        if (isSelected) {
          sports.add(sport);
        }
      });

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

      if (sports.isEmpty && otherController.text.trim().isEmpty) {
        _showMessage('Please choose a sport for your event.');
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

    String getPosterURL(List<String> sportList) {
      String posterURL = "";
      switch (sportList[0]) {
        case "Football":
          posterURL = football;
          break;
        case "Basketball":
          posterURL = basketball;
          break;
        case "Badminton":
          posterURL = badminton;
          break;
        case "Futsal":
          posterURL = futsal;
          break;
        case "Jogging":
          posterURL = jogging;
          break;
        case "Gym":
          posterURL = gym;
          break;
        case "Tennis":
          posterURL = tennis;
          break;
        case "Hiking":
          posterURL = hiking;
          break;
        case "Cycling":
          posterURL = cycling;
          break;
        default:
          posterURL = general;
          break;
      }
      return posterURL;
    }

    Future<void> createEvent() async {
      if (validateEvent()) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        String location = _locationData['location'] ?? "Unknown";
        List<String> sports = [];
        bool isOther = false;

        selectedSports.forEach((sport, isSelected) {
          if (isSelected) {
            if (sport == "Other") {
              sports.add(otherController.text);
              isOther = true;
            } else {
              sports.add(sport);
            }
          }
        });

        if (_formKey.currentState!.validate()) {
          setState(() {
            isCreating = true;
          });

          try {
            final String eventId =
                FirebaseFirestore.instance.collection('events').doc().id;

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
              'sports': sports,
              'timestamp': Timestamp.now(),
              'posterURL': getPosterURL(sports),
              'requestList': [],
              'acceptedList': [],
              'isOther': isOther,
            };

            // Add the post document to Firestore
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .set(eventData);

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
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
              selectedSports.updateAll((sport, isSelected) => false);
            });
          } catch (error) {
            _showMessage('Error creating post: $error');
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
                          "Create Event",
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
                    SizedBox(
                      height: 300, // Adjusted height
                      child: SportsList(
                        onSelectionChanged: (selected) {
                          setState(() {
                            selectedSports = selected;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedSports['Other'] ==
                        true) // Conditionally display the text field
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
