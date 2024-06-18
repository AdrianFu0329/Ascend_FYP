import 'dart:async';

import 'package:ascend_fyp/database/firebase_notifications.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/media_card.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/notifications/screens/notification_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:video_player/video_player.dart';
import '../../database/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  StreamSubscription<QuerySnapshot>? notificationsSubscription;
  bool hasNewNotifications = false;
  //Map<String, Map<String, dynamic>> postList = {};
  Map<String, dynamic> postList = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FirebaseNotifications.getFirebaseMessagingToken();

    // Listen for notifications
    notificationsSubscription = getNotiForCurrentUser(currentUser.uid).listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            hasNewNotifications = true;
          });
        }
      },
      onError: (error) {
        debugPrint("Error in notification stream: $error");
      },
    );

    debugPrint("Notification subscription started");

    // Fetch posts from database and preload media
    fetchPostsFromDatabase();
  }

  @override
  void dispose() {
    notificationsSubscription?.cancel();
    debugPrint("Notification subscription canceled");
    super.dispose();
  }

  Future<void> fetchPostsFromDatabase() async {
    DatabaseReference postsRef = FirebaseDatabase.instance.ref('posts');
    DatabaseEvent event = await postsRef.orderByChild('timestamp').once();

    Map<String, dynamic> loadedPosts = {};

    if (event.snapshot.value != null) {
      // Convert data into a Map<String, dynamic>
      Map<dynamic, dynamic> postsData =
          event.snapshot.value as Map<dynamic, dynamic>;
      postsData.forEach((key, value) {
        loadedPosts[key.toString()] = Map<String, dynamic>.from(value as Map);
      });

      // Sort the posts by timestamp in descending order
      List<MapEntry<String, dynamic>> sortedPosts =
          loadedPosts.entries.toList();
      sortedPosts
          .sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));

      loadedPosts = {for (var entry in sortedPosts) entry.key: entry.value};
    }

    // Preload media for each post
    List<Future<dynamic>> futures = [];
    for (var postId in loadedPosts.keys) {
      var post = loadedPosts[postId]!;
      if (post['type'] == 'Images') {
        List<String> photoURLs = List<String>.from(post['imageURLs'] ?? []);
        futures.add(getPostImg(photoURLs).then((images) {
          post['images'] = images;
        }));
      } else if (post['type'] == 'Video') {
        futures
            .add(initializeVideoController(post['videoURL']).then((controller) {
          post['videoController'] = controller;
        }));
      }
    }

    // Wait for all media to be loaded
    await Future.wait(futures);

    // Update state with loaded posts and set loading state to false
    setState(() {
      postList = loadedPosts;
      isLoading = false;
    });
  }

  Future<VideoPlayerController?> initializeVideoController(
      String videoURL) async {
    try {
      final videoCacheManager = DefaultCacheManager();
      final fileInfo = await videoCacheManager.getFileFromCache(videoURL);

      VideoPlayerController controller;

      if (fileInfo != null) {
        controller = VideoPlayerController.file(fileInfo.file);
      } else {
        Uri videoUri = Uri.parse(videoURL);
        controller = VideoPlayerController.networkUrl(videoUri);
      }

      await controller.initialize();

      return controller;
    } catch (e) {
      debugPrint("Error loading video: $e");
      return null;
    }
  }

  Future<void> refreshPosts() async {
    // Reset state and reload posts
    setState(() {
      postList = {};
      isLoading = true;
    });
    await fetchPostsFromDatabase();
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
        body: isLoading
            ? const Center(child: ContainerLoadingAnimation())
            : CustomScrollView(
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
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              modalBottomSheet(const NotificationModal());
                            },
                            icon: const Icon(Icons.notifications),
                            color: Colors.white,
                            iconSize: 24,
                          ),
                          if (hasNewNotifications)
                            Positioned(
                              right: 11,
                              top: 11,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 8,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  postList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(child: Text("No posts available")))
                      : SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemBuilder: (BuildContext context, int index) {
                            String postId = postList.keys.elementAt(index);
                            Map<String, dynamic> data = postList[postId]!;

                            String title = data['title'];
                            List<ImageWithDimension> images =
                                data['images'] ?? [];
                            VideoPlayerController? videoController =
                                data['videoController'];
                            List<String> likes =
                                List<String>.from(data['likes'] ?? []);
                            String userId = data['userId'];
                            int timestamp = data['timestamp'];
                            String description = data['description'];
                            String location = data['location'];
                            String type = data['type'];

                            return type == "Images"
                                ? MediaCard(
                                    index: index,
                                    postId: postId,
                                    media: images,
                                    title: title,
                                    userId: userId,
                                    likes: likes,
                                    timestamp:
                                        Timestamp.fromMillisecondsSinceEpoch(
                                            timestamp),
                                    description: description,
                                    location: location,
                                    type: type,
                                  )
                                : MediaCard(
                                    index: index,
                                    postId: postId,
                                    media: videoController,
                                    title: title,
                                    userId: userId,
                                    likes: likes,
                                    timestamp:
                                        Timestamp.fromMillisecondsSinceEpoch(
                                            timestamp),
                                    description: description,
                                    location: location,
                                    type: type,
                                  );
                          },
                          childCount: postList.length,
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }
}
