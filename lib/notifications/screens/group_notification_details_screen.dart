import 'package:ascend_fyp/chat/screens/chat_screen.dart';
import 'package:ascend_fyp/chat/service/chat_service.dart';
import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupNotificationDetailsScreen extends StatefulWidget {
  final String notificationId;
  final String groupId;
  final String ownerUserId;
  final String requestUserId;
  final Timestamp timestamp;
  final String title;
  final String message;
  final String type;
  final String requestUserLocation;

  const GroupNotificationDetailsScreen({
    super.key,
    required this.notificationId,
    required this.groupId,
    required this.ownerUserId,
    required this.requestUserId,
    required this.timestamp,
    required this.title,
    required this.message,
    required this.type,
    required this.requestUserLocation,
  });

  @override
  State<GroupNotificationDetailsScreen> createState() =>
      _GroupNotificationDetailsScreenState();
}

class _GroupNotificationDetailsScreenState
    extends State<GroupNotificationDetailsScreen> {
  String groupTitle = "";
  String groupSport = "";
  String participants = "";
  List<dynamic> requestList = [];
  List<dynamic> memberList = [];
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  Future<void> _fetchGroupData() async {
    final groupData = await getGroupData(widget.groupId);
    setState(() {
      groupTitle = groupData['name'];
      groupSport = groupData['sports'];
      participants = groupData['participants'].toString();
      requestList = List<dynamic>.from(groupData['requestList']);
      memberList = List<dynamic>.from(groupData['memberList']);
    });
  }

  void _showMessage(String message, {VoidCallback? onOkPressed}) {
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
                if (onOkPressed != null) {
                  onOkPressed();
                }
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

  Future<void> deleteNotification() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notification')
        .doc(widget.notificationId)
        .delete();
  }

  void onDenyPressed() async {
    try {
      setState(() {
        requestList.remove(widget.requestUserId);
      });

      DocumentReference postRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      await postRef.update({'requestList': requestList});

      // Delete Notification
      await deleteNotification();

      // Notification for user that made the request
      final String notificationId = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.requestUserId)
          .collection('notification')
          .doc()
          .id;

      final Map<String, dynamic> notificationData = {
        'notificationId': notificationId,
        'eventId': widget.groupId,
        'ownerUserId': currentUser.uid,
        'title': "Request to join sport event rejected.",
        'message':
            "Your request to join ${currentUser.displayName}'s Sport Event '$groupTitle' has been rejected...",
        'requestUserId': widget.ownerUserId,
        'timestamp': Timestamp.now(),
        'type': "General",
      };

      // Add the notification document to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.requestUserId)
          .collection('notification')
          .doc(notificationId)
          .set(notificationData);

      _showMessage("Your response has been recorded!", onOkPressed: () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showMessage(
          "There was an unexpected error while recording your response. Try again later!");
    }
  }

  void onApprovePressed() async {
    try {
      setState(() {
        memberList.add(widget.requestUserId);
        requestList.remove(widget.requestUserId);
      });

      DocumentReference postRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      await postRef.update({'requestList': requestList});
      await postRef.update({'memberList': memberList});

      // Leaderboard data for new user
      final Map<String, dynamic> userLeaderboardData = {
        'userId': widget.requestUserId,
        'role': "Member",
        'dateJoined': Timestamp.now(),
        'participationPoints': 0,
      };

      // Add new member to Leaderboard
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('leaderboard')
          .doc(widget.requestUserId)
          .set(userLeaderboardData);

      // Delete Notification
      await deleteNotification();

      // Notification for user that made the request
      final String notificationId = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.requestUserId)
          .collection('notification')
          .doc()
          .id;

      final Map<String, dynamic> notificationData = {
        'notificationId': notificationId,
        'eventId': widget.groupId,
        'ownerUserId': currentUser.uid,
        'title': "Request to join community group approved!",
        'message':
            "Your request to join ${currentUser.displayName}'s Community Group '$groupTitle' has been approved!",
        'requestUserId': widget.ownerUserId,
        'timestamp': Timestamp.now(),
        'type': "General",
      };

      // Add the notification document to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.requestUserId)
          .collection('notification')
          .doc(notificationId)
          .set(notificationData);

      _showMessage("Your response has been recorded!", onOkPressed: () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showMessage(
          "There was an unexpected error while recording your response. Try again later!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: FutureBuilder<Image>(
              future: getPoster(eventsNotification), // Change
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingAnimation(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "An unexpected error occurred. Try again later...",
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: snapshot.data!.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 145,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.75),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "User Location: ",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.requestUserLocation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.greenAccent,
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(
                                color: Colors.greenAccent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final Map<String, dynamic> userData =
                              await getUserData(widget.requestUserId);
                          final username = userData["username"] ?? "Unknown";
                          final photoUrl = userData["photoURL"] ?? "Unknown";
                          final userFcmToken =
                              userData["fcmToken"] ?? "Unknown";

                          String? chatRoomId =
                              await ChatService().createChatRoom(
                            widget.requestUserId,
                            username,
                            photoUrl,
                          );

                          if (chatRoomId != null) {
                            // Push to chat screen with chosen user
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              SlidingNav(
                                builder: (context) => ChatScreen(
                                  receiverUserId: widget.requestUserId,
                                  receiverUsername: username,
                                  receiverPhotoUrl: photoUrl,
                                  receiverFcmToken: userFcmToken,
                                  chatRoomId: chatRoomId,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Contact User',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Merriweather Sans',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      color: Colors.red,
                      thickness: 4,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.group,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            groupTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            "Sports Involved: $groupSport",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_2_rounded,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${memberList.length} / $participants",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 150,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.greenAccent,
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color: Colors.greenAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      onPressed: onApprovePressed,
                      child: Text(
                        'Approve',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Merriweather Sans',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 150,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromRGBO(194, 0, 0, 1),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color: Color.fromRGBO(194, 0, 0, 1),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      onPressed: onDenyPressed,
                      child: const Text(
                        'Deny',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Merriweather Sans',
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(247, 243, 237, 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
