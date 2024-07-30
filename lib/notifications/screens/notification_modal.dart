import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/notifications/widgets/notification_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    bool showRedDot = true;

    Widget makeDismissible({required Widget child}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(showRedDot),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notifications",
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getNotiForCurrentUser(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CustomLoadingAnimation(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      showRedDot = false;
                      return const Center(
                        child: Text('No notifications at the moment!'),
                      );
                    }

                    List<DocumentSnapshot> notiList = snapshot.data!.docs;

                    return ListView.builder(
                      controller: controller,
                      itemCount: notiList.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot doc = notiList[index];
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        debugPrint("GroupID: ${data['groupId']}");

                        return Dismissible(
                          key: Key(
                              doc.id), // Unique key for each notification card
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (DismissDirection direction) async {
                            // Confirm deletion
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  content: Text(
                                    "Are you sure you want to delete this notification?",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        "Delete",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (DismissDirection direction) {
                            // Delete notification from Firestore after swipe action
                            deleteNotification(data['notificationId']);
                          },
                          child: NotificationCard(
                            notificationId: data['notificationId'],
                            eventId: data['eventId'] ?? data['groupId'],
                            groupId: data['groupId'] ?? "Unknown",
                            ownerUserId: data['ownerUserId'],
                            requestUserId: data['requestUserId'],
                            timestamp: data['timestamp'],
                            title: data['title'],
                            message: data['message'],
                            type: data['type'],
                            requestUserLocation: data['type'] == "General" ||
                                    data['type'] == "Event-General"
                                ? "Unknown"
                                : data['requestUserLocation'],
                          ),
                        );
                      },
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

  Future<void> deleteNotification(String notificationId) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('notification')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      // Handle error as needed
    }
  }
}
