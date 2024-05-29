import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/widgets/creation_sport_list.dart';
import 'package:ascend_fyp/widgets/loading.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedSports;
  bool isCreating = false;
  final ValueNotifier<bool> resetNotifierSportList = ValueNotifier(false);
  final ValueNotifier<bool> resetNotifierParticipation = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    void showMessage(String message) {
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
        showMessage('Please enter a group name.');
        return false;
      }

      if (participantsController.text.trim().isEmpty) {
        showMessage('Please enter a desired group member count.');
        return false;
      }

      if (selectedSports == null && otherController.text.trim().isEmpty) {
        showMessage('Please choose a focus sport for your group.');
        return false;
      }

      return true;
    }

    String getPosterURL(String selectedSport) {
      String posterURL = "";
      switch (selectedSport) {
        case "Football":
          posterURL = groupFootball;
          break;
        case "Basketball":
          posterURL = groupBasketball;
          break;
        case "Badminton":
          posterURL = groupBadminton;
          break;
        case "Futsal":
          posterURL = groupFutsal;
          break;
        case "Jogging":
          posterURL = groupJogging;
          break;
        case "Gym":
          posterURL = groupGym;
          break;
        case "Tennis":
          posterURL = groupTennis;
          break;
        case "Hiking":
          posterURL = groupHiking;
          break;
        case "Cycling":
          posterURL = groupCycling;
          break;
        default:
          posterURL = groupGeneral;
          break;
      }
      return posterURL;
    }

    Future<void> createGroup() async {
      if (validateGroup()) {
        final currentUser = FirebaseAuth.instance.currentUser!;
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
              'ownerUserId': FirebaseAuth.instance.currentUser!.uid,
              'sports': selectedSports,
              'timestamp': Timestamp.now(),
              'posterURL': getPosterURL(selectedSports!),
              'requestList': [],
              'memberList': acceptedList,
              'isOther': isOther,
            };

            // Leaderboard data at creation
            final Map<String, dynamic> userLeaderboardData = {
              'userId': currentUser.uid,
              'role': "Owner",
              'dateJoined': Timestamp.now(),
              'groupEventsJoined': 0,
            };

            // Add the group document to Firestore
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .set(groupData);

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('groups')
                .doc(groupId)
                .set(groupData);

            // Leaderboard data
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .collection('leaderboard')
                .doc(currentUser.uid)
                .set(userLeaderboardData);

            showMessage('Group created successfully');

            nameController.clear();
            participantsController.clear();
            otherController.clear();
            setState(() {
              isCreating = false;
              selectedSports = null;
            });
            resetNotifierSportList.value = !resetNotifierSportList.value;
            resetNotifierParticipation.value =
                !resetNotifierParticipation.value;
          } catch (error) {
            showMessage('Error creating group: $error');
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
