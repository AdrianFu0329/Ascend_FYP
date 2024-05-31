import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/notification_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

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
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> notiList = snapshot.data!.docs;

                      if (notiList.isEmpty) {
                        return const Center(
                          child: Text('No notifications at the moment!'),
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: notiList.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot doc = notiList[index];
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;

                          return NotificationCard(
                            notificationId: data['notificationId'],
                            eventId: data['type'] == "Events" ||
                                    data['type'] == "General"
                                ? data['eventId']
                                : data['groupId'],
                            ownerUserId: data['ownerUserId'],
                            requestUserId: data['requestUserId'],
                            timestamp: data['timestamp'],
                            title: data['title'],
                            message: data['message'],
                            type: data['type'],
                            requestUserLocation:
                                data['requestUserLocation'] ?? "Unknown",
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No notifications at the moment!'),
                      );
                    }
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
