import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/widgets/creation_sport_list.dart';
import 'package:ascend_fyp/widgets/custom_text_field.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditGroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupTitle;
  final String groupSport;
  final String participants;
  final String posterURL;
  final bool isOther;

  const EditGroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupTitle,
    required this.groupSport,
    required this.participants,
    required this.isOther,
    required this.posterURL,
  });

  @override
  _EditGroupDetailsScreenState createState() => _EditGroupDetailsScreenState();
}

class _EditGroupDetailsScreenState extends State<EditGroupDetailsScreen> {
  late TextEditingController groupTitleController;
  late TextEditingController groupParticipantsController;
  late TextEditingController groupSportController;
  late TextEditingController otherController;
  late bool isOtherGroup;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> resetNotifierSportList = ValueNotifier(false);
  final ValueNotifier<bool> resetNotifierParticipation = ValueNotifier(false);
  String? selectedSports;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    groupTitleController = TextEditingController(text: widget.groupTitle);
    groupParticipantsController =
        TextEditingController(text: widget.participants);
    groupSportController = TextEditingController(text: widget.groupSport);
    isOtherGroup = widget.isOther;
    otherController = widget.isOther
        ? TextEditingController(text: widget.groupSport)
        : TextEditingController();
    selectedSports =
        widget.isOther ? "Other" : widget.groupSport; // Initial Sport
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

  bool isEditButtonEnabled() {
    return groupTitleController.text.isNotEmpty ||
        groupParticipantsController.text.isNotEmpty ||
        groupSportController.text.isNotEmpty;
  }

  Future<void> updateFields() async {
    setState(() {
      isUpdating = true;
      if (otherController.text.isNotEmpty) {
        isOtherGroup = true;
        selectedSports = otherController.text.trim();
      }
    });

    DocumentReference eventRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    try {
      await eventRef.update({
        'name': groupTitleController.text.trim(),
        'sports': selectedSports,
        'participants': groupParticipantsController.text.trim(),
        'isOther': isOtherGroup,
        'posterURL': getPosterURL(selectedSports!),
      });
      setState(() {
        isUpdating = false;
      });
      _showMessage('Group details updated successfully!');
    } catch (error) {
      setState(() {
        isUpdating = false;
      });
      _showMessage('An error occurred. Failed to update group details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Edit Group Details',
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
                      hintText: "Group Name",
                      controller: groupTitleController,
                      prefixIcon: const Icon(
                        Icons.calendar_month,
                        size: 30,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: "No. of Participants (eg: 10)",
                      controller: groupParticipantsController,
                      prefixIcon: const Icon(
                        Icons.group,
                        size: 30,
                        color: Color.fromRGBO(247, 243, 237, 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300, // Adjusted height
                          child: CreationSportsList(
                            onSelectionChanged: (selected) {
                              setState(() {
                                selectedSports = selected;
                                if (selected != 'Other') {
                                  isOtherGroup = false;
                                  otherController.clear();
                                }
                              });
                            },
                            resetNotifier: resetNotifierSportList,
                            initialSelectedSport:
                                widget.isOther ? "Other" : widget.groupSport,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (selectedSports ==
                        'Other') // Conditionally display the text field
                      CustomTextField(
                        controller: otherController,
                        hintText: "Other (please specify)",
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
                                'name': groupTitleController.text.trim(),
                                'sports': selectedSports,
                                'participants':
                                    groupParticipantsController.text.trim(),
                                'isOther': isOtherGroup,
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
