import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/pages/set_location_screen.dart';
import 'package:ascend_fyp/widgets/creation_sport_list.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';

class CreateGroupsScreen extends StatefulWidget {
  const CreateGroupsScreen({super.key});

  @override
  State<CreateGroupsScreen> createState() => _CreateGroupsScreenState();
}

class _CreateGroupsScreenState extends State<CreateGroupsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController participantsController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  Map<String, dynamic> _locationData = {};
  String? location;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedSports;
  bool isCreating = false;
  final ValueNotifier<bool> resetNotifierSportList = ValueNotifier(false);
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

    bool validateGroup() {
      if (nameController.text.trim().isEmpty) {
        _showMessage('Please enter a group name.');
        return false;
      }

      if (participantsController.text.trim().isEmpty) {
        _showMessage('Please enter a desired group member count.');
        return false;
      }

      if (selectedSports == null && otherController.text.trim().isEmpty) {
        _showMessage('Please choose a focus sport for your group.');
        return false;
      }

      return true;
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

    String getPosterURL(String selectedSport) {
      String posterURL = "";
      switch (selectedSport) {
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

    Future<void> createGroup() async {
      if (validateGroup()) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        String location = _locationData['location'] ?? "Unknown";
        bool isOther = false;

        if (_formKey.currentState!.validate()) {
          setState(() {
            isCreating = true;
            if (otherController.text.isNotEmpty) {
              isOther = true;
              selectedSports = otherController.text.trim();
            }
          });

          try {
            final String groupId =
                FirebaseFirestore.instance.collection('groups').doc().id;
            List<String> acceptedList = [];

            acceptedList.add(currentUser.uid);

            final Map<String, dynamic> groupData = {
              'groupId': groupId,
              'name': nameController.text.trim(),
              'participants': participantsController.text.trim(),
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'location': location,
              'sports': selectedSports,
              'timestamp': Timestamp.now(),
              'posterURL': getPosterURL(selectedSports!),
              'requestList': [],
              'acceptedList': acceptedList,
              'isOther': isOther,
            };

            // Add the group document to Firestore
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .set(groupData);

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('events')
                .doc(groupId)
                .set(groupData);

            _showMessage('Event created successfully');

            nameController.clear();
            participantsController.clear();
            _locationData.clear();
            otherController.clear();
            setState(() {
              isCreating = false;
              selectedSports = null;
            });
            resetNotifierSportList.value = !resetNotifierSportList.value;
            resetNotifierParticipation.value =
                !resetNotifierParticipation.value;
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
                          "Create Group",
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
                      hintText: "Group Name",
                      controller: nameController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "Desired Number of Members (eg: 10)",
                      controller: participantsController,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300, // Adjusted height
                      child: CreationSportsList(
                        onSelectionChanged: (selected) {
                          setState(() {
                            selectedSports = selected;
                          });
                        },
                        resetNotifier: resetNotifierSportList,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            Text("Set Group's Location"),
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
                          if (validateGroup()) {
                            createGroup();
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
