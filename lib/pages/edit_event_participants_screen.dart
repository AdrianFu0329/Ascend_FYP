import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/user_details_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditEventParticipantsScreen extends StatefulWidget {
  final String eventId;
  final List<dynamic> acceptedList;

  const EditEventParticipantsScreen({
    super.key,
    required this.eventId,
    required this.acceptedList,
  });

  @override
  State<EditEventParticipantsScreen> createState() =>
      _EditEventParticipantsScreenState();
}

class _EditEventParticipantsScreenState
    extends State<EditEventParticipantsScreen> {
  late List<dynamic> acceptedList;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    acceptedList = List.from(widget.acceptedList);
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

  Future<void> updateFields() async {
    setState(() {
      isUpdating = true;
    });

    DocumentReference eventRef =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);

    try {
      await eventRef.update({
        'acceptedList': acceptedList,
      });
      setState(() {
        isUpdating = false;
      });
      _showMessage('Event participants updated successfully!');
    } catch (error) {
      setState(() {
        isUpdating = false;
      });
      _showMessage(
          'An error occurred. Failed to update event participants: $error');
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
        leading: PopScope(
          canPop: false,
          onPopInvoked: ((didPop) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop(
              {
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
                  'acceptedList': acceptedList,
                },
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: getParticipantsForCurrentEvent(widget.eventId),
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
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                participantsList.remove(userId);
                                acceptedList = participantsList;
                              });
                              updateFields();
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
                  child: ContainerLoadingAnimation(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
