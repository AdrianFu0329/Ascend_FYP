import 'dart:async';

import 'package:ascend_fyp/database/firebase_notifications.dart';
import 'package:ascend_fyp/general%20widgets/post_loading_widget.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/models/video_with_dimension.dart';
import 'package:ascend_fyp/notifications/screens/notification_modal.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/notifications/service/notification_service.dart';
import 'package:ascend_fyp/social%20media/widgets/social_media_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../database/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot>? postsStream;
  StreamSubscription<QuerySnapshot>? notificationsSubscription;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    FirebaseNotifications.getFirebaseMessagingToken();
    // Listen for notifications
    notificationsSubscription = getNotiForCurrentUser(currentUser.uid).listen(
      (snapshot) {
        debugPrint(
            "Notifications snapshot received: ${snapshot.docs.length} docs");

        var id = 0;

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          final String title = data['title'];
          final String body = data['message'];

          try {
            NotificationService.showInstantNotification(id, title, body);
          } catch (e) {
            debugPrint("Error displaying notification: $e");
          }
          id++;
        }
      },
      onError: (error) {
        debugPrint("Error in notification stream: $error");
      },
    );

    debugPrint("Notification subscription started");
    postsStream = getPostsFromDatabase();
  }

  @override
  void dispose() {
    notificationsSubscription?.cancel();
    debugPrint("Notification subscription canceled");
    super.dispose();
  }

  Future<void> refreshPosts() async {
    setState(() {
      postsStream = getPostsFromDatabase();
    });
  }

  Widget loadingCard() {
    return SizedBox(
      width: 135,
      height: 250,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 175,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: ContainerLoadingAnimation(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void modalBottomSheet(Widget screen) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        isScrollControlled: true,
        builder: (context) => screen,
      );
    }

    return RefreshIndicator(
      onRefresh: refreshPosts,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 36, 0, 36),
                child: Image.asset(
                  "lib/assets/images/logo_noBg.png",
                  width: 130,
                  height: 50,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    modalBottomSheet(const NotificationModal());
                  },
                  icon: const Icon(Icons.notifications),
                  color: Colors.white,
                  iconSize: 24,
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CustomLoadingAnimation(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  List postList = snapshot.data!.docs;
                  return SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = postList[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      String postId = data['postId'];
                      String title = data['title'];
                      List<String> photoURLs =
                          List<String>.from(data['imageURLs'] ?? []);
                      String videoURL = data['videoURL'] ?? "Unknown";
                      List<String> likes = List<String>.from(data['likes']);
                      String userId = data['userId'];
                      Timestamp timestamp = data['timestamp'];
                      String description = data['description'];
                      String location = data['location'];
                      String type = data['type'];

                      return type == "Images"
                          ? FutureBuilder<dynamic>(
                              future: getPostImg(photoURLs),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const PostLoadingWidget();
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      "An unexpected error occurred. Try again later...",
                                    ),
                                  );
                                } else {
                                  List<ImageWithDimension> images =
                                      snapshot.data!;
                                  return SocialMediaCard(
                                    index: index,
                                    postId: postId,
                                    media: images,
                                    title: title,
                                    userId: userId,
                                    likes: likes,
                                    timestamp: timestamp,
                                    description: description,
                                    location: location,
                                    type: type,
                                  );
                                }
                              },
                            )
                          : //VideoWithDimension video = snapshot.data!;
                          SocialMediaCard(
                              index: index,
                              postId: postId,
                              media: videoURL,
                              title: title,
                              userId: userId,
                              likes: likes,
                              timestamp: timestamp,
                              description: description,
                              location: location,
                              type: type,
                            );
                    },
                    childCount: postList.length,
                  );
                } else {
                  return const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Center(
                          child: Text('No posts at the moment!'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
