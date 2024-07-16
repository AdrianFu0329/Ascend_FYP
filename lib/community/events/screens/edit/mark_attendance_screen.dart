import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/user_details_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;
  final String groupId;
  final List<dynamic> acceptedList;
  final List<dynamic> attendanceList;

  const MarkAttendanceScreen({
    super.key,
    required this.eventId,
    required this.acceptedList,
    required this.groupId,
    required this.attendanceList,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late List<dynamic> attendanceList;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    attendanceList = List.from(widget.attendanceList);
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

  Future<void> updateLeaderboard(String userId) async {
    DocumentReference userLeaderboardRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('leaderboard')
        .doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userLeaderboardRef.get();

      if (docSnapshot.exists) {
        int currentEventsJoined = docSnapshot.get('participationPoints');
        int updatedEventsJoined = currentEventsJoined + 9;

        // Update the document with the new value
        await userLeaderboardRef.update({
          'participationPoints': updatedEventsJoined,
        });
      }
    } catch (e) {
      debugPrint("Leaderboard data for $userId did not update successfull: $e");
    }
  }

  Future<void> updateAttendanceList(String userId) async {
    setState(() {
      isUpdating = true;
    });

    DocumentReference eventRef = widget.groupId != "Unknown"
        ? FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('events')
            .doc(widget.eventId)
        : FirebaseFirestore.instance.collection('events').doc(widget.eventId);

    try {
      await eventRef.update({
        'attendanceList': attendanceList,
      });
      await updateLeaderboard(userId);
      _showMessage('Attendance updated successfully!');
      setState(() {
        isUpdating = false;
      });
    } catch (error) {
      _showMessage('An error occurred. Failed to update event attendance');
      setState(() {
        isUpdating = false;
      });
      debugPrint(
          'An error occurred. Failed to update event attendance: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Event Participants',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: getParticipantsForCurrentEvent(
                  widget.eventId, widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CustomLoadingAnimation());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No participants found.'));
                }

                final List<dynamic> participantsList =
                    snapshot.data!['acceptedList'];

                if (participantsList.isEmpty) {
                  return const Center(child: Text('No participants found.'));
                }

                return ListView.builder(
                  itemCount: participantsList.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(participantsList[index]),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CustomLoadingAnimation();
                        } else if (userSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${userSnapshot.error}'),
                          );
                        } else if (!userSnapshot.hasData) {
                          return const Center(
                              child: Text('User data not found.'));
                        }
                        final userId = participantsList[index];
                        final userData = userSnapshot.data!;
                        return UserDetailsTile(
                          userId: userId,
                          username: userData['username'],
                          photoURL: userData['photoURL'],
                          trailing: IconButton(
                            icon: Icon(
                              attendanceList.contains(userId)
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                attendanceList.add(userId);
                              });
                              updateAttendanceList(userId);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (isUpdating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0),
                child: const Center(
                  child: CustomLoadingAnimation(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
