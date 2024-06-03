import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/edit_group_details_screen.dart';
import 'package:ascend_fyp/pages/edit_group_participants_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;
  final String groupTitle;
  final String groupSport;
  final String participants;
  final String posterURL;
  final List<dynamic> memberList;
  final bool isOther;

  const GroupSettingsScreen({
    super.key,
    required this.groupId,
    required this.groupTitle,
    required this.groupSport,
    required this.participants,
    required this.posterURL,
    required this.memberList,
    required this.isOther,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late String groupSport;
  late String groupTitle;
  late String participants;
  late String posterURL;
  late List<dynamic> memberList;
  late bool isOther;

  @override
  void initState() {
    super.initState();
    groupSport = widget.groupSport;
    groupTitle = widget.groupTitle;
    participants = widget.participants;
    posterURL = widget.posterURL;
    memberList = widget.memberList;
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

  Future<bool> deleteGroup() async {
    try {
      DocumentReference groupDocRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

      CollectionReference leaderboardCollectionRef =
          groupDocRef.collection('leaderboard');

      QuerySnapshot leaderboardSnapshot = await leaderboardCollectionRef.get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DocumentSnapshot doc in leaderboardSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await groupDocRef.delete();

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
          'Group Settings',
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
                'title': groupTitle,
                'sports': groupSport,
                'participants': participants,
                'isOther': isOther,
                'posterURL': posterURL,
                'memberList': memberList,
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
                  'title': groupTitle,
                  'sports': groupSport,
                  'participants': participants,
                  'isOther': isOther,
                  'posterURL': posterURL,
                  'memberList': memberList,
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
              "Are you sure you would like to delete your community group?",
              true,
              onYesPressed: () async {
                bool isDeleted = await deleteGroup();
                if (isDeleted) {
                  _showMessage(
                    "Group deleted successfully",
                    false,
                    onOKPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                  );
                } else {
                  _showMessage(
                      "Unable to delete group. Try again later...", false);
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
                  Text('Delete Group'),
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
                      builder: (context) => EditGroupDetailsScreen(
                        groupId: widget.groupId,
                        groupSport: widget.groupSport,
                        groupTitle: widget.groupTitle,
                        participants: widget.participants,
                        posterURL: widget.posterURL,
                        isOther: widget.isOther,
                      ),
                    ),
                  );

                  if (changeResult != null) {
                    setState(() {
                      groupSport = changeResult['sports'];
                      groupTitle = changeResult['title'];
                      participants = changeResult['participants'];
                      posterURL = changeResult['posterURL'];
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
                    Text('Edit Group Details'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final changeResult = await Navigator.of(context).push(
                    SlidingNav(
                      builder: (context) => EditGroupParticipantsScreen(
                        groupId: widget.groupId,
                        memberList: widget.memberList,
                      ),
                    ),
                  );

                  if (changeResult != null) {
                    setState(() {
                      memberList = changeResult['memberList'];
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
                        Text('Edit Group Members'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
