import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/general%20widgets/media_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:video_player/video_player.dart';

class CurrentUserPosts extends StatefulWidget {
  const CurrentUserPosts({super.key});

  @override
  State<CurrentUserPosts> createState() => _CurrentUserPostsState();
}

class _CurrentUserPostsState extends State<CurrentUserPosts> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> postList = {};
  bool isLoading = true;

  @override
  void initState() {
    fetchPostsFromDatabase();
    super.initState();
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

      loadedPosts
          .removeWhere((key, value) => value['userId'] != currentUser.uid);

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SliverToBoxAdapter(
            child: Center(child: CustomLoadingAnimation(page: "profile")))
        : postList.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/images/empty_posts.png",
                        width: 250,
                        height: 250,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You don't have any posts! Start creating now!",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            : SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemBuilder: (BuildContext context, int index) {
                  String postId = postList.keys.elementAt(index);
                  Map<String, dynamic> data = postList[postId]!;

                  String title = data['title'];
                  List<ImageWithDimension> images = data['images'] ?? [];
                  VideoPlayerController? videoController =
                      data['videoController'];
                  String videoURL = data['videoURL'] ?? "Unknown";
                  List<String> likes = List<String>.from(data['likes'] ?? []);
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
                              Timestamp.fromMillisecondsSinceEpoch(timestamp),
                          description: description,
                          location: location,
                          type: type,
                          videoURL: videoURL,
                          page: "Profile",
                        )
                      : MediaCard(
                          index: index,
                          postId: postId,
                          media: videoController,
                          title: title,
                          userId: userId,
                          likes: likes,
                          timestamp:
                              Timestamp.fromMillisecondsSinceEpoch(timestamp),
                          description: description,
                          location: location,
                          type: type,
                          videoURL: videoURL,
                          page: "Profile",
                        );
                },
                childCount: postList.length,
              );
  }
}
