import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/media_card.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.isCurrentUser,
  });

  @override
  State<UserProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserProfileScreen> {
  late bool followed;
  int followerCount = 0;
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String username;
  late String email;
  late String photoURL;
  late String description;
  late List<dynamic> currentFollowing;
  late List<dynamic> following;
  late List<dynamic> followers;
  Map<String, dynamic>? userData;
  Map<String, dynamic> postList = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    refreshProfileData();
    checkIfFollowed();
    fetchUserData();
    fetchPostsFromDatabase();
    super.initState();
  }

  Future<void> fetchUserData() async {
    try {
      final data = await getUserData(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
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

      loadedPosts.removeWhere((key, value) => value['userId'] != widget.userId);

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

  Future<void> onFollowPressed() async {
    Map<String, dynamic> userData = await getUserData(widget.userId);
    List<dynamic> userFollowers = userData['followers'] ?? [];
    if (!followed) {
      // Add user's email to current user following list
      currentFollowing.add(widget.userId);
      // Add current user to user's followers list
      userFollowers.add(currentUser.uid);
    } else {
      // Remove user's email from current user following list
      currentFollowing.remove(widget.userId);
      // Remove current user from user's followers list
      userFollowers.remove(currentUser.uid);
    }

    // Update current user following list
    DocumentReference currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    await currentUserRef.update({'following': currentFollowing});

    // Update user's follower list
    DocumentReference userFollowersRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    await userFollowersRef.update({'followers': userFollowers});

    setState(() {
      followed = !followed;
      followers = userFollowers;
    });
  }

  ButtonStyle getFollowButtonStyle() {
    return ButtonStyle(
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
        followed ? Colors.red : Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Future<void> refreshProfileData() async {
    final userData = await getUserData(widget.userId);

    setState(() {
      username = userData["username"] ?? "Unknown";
      description = userData["description"] == ""
          ? "Empty~~ Add one today!"
          : userData["description"];
      email = userData['email'] ?? "Unknown";
      photoURL = userData["photoURL"] ?? "Unknown";
      following = userData['following'] ?? [];
      followers = userData['followers'] ?? [];
      checkIfFollowed();
    });
  }

  Future<void> checkIfFollowed() async {
    final currentUserData = await getUserData(currentUser.uid);
    setState(() {
      followed = currentUserData['following'].contains(widget.userId);
      currentFollowing = currentUserData['following'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshProfileData,
      backgroundColor: Theme.of(context).cardColor,
      color: Colors.red,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProfilePicture(
                                userId: widget.userId,
                                photoURL: photoURL,
                                radius: 40,
                                onTap: () {},
                              ),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        (userData?['followers'] ?? [])
                                            .length
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        "Followers",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 28),
                                  Column(
                                    children: [
                                      Text(
                                        (userData?['following'] ?? [])
                                            .length
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        "Following",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(
                            userData?['username'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: widget.isCurrentUser
                              ? const SizedBox(height: 12)
                              : ElevatedButton(
                                  onPressed: onFollowPressed,
                                  style: getFollowButtonStyle(),
                                  child: Text(
                                    followed ? "Unfollow" : "Follow",
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.red,
                    thickness: 4,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: ContainerLoadingAnimation()))
                : postList.isEmpty
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
                          String videoURL = data['videoURL'] ?? "Unknown";
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
                                      Timestamp.fromMillisecondsSinceEpoch(
                                          timestamp),
                                  description: description,
                                  location: location,
                                  type: type,
                                  videoURL: videoURL,
                                  page: "Profile",
                                );
                        },
                        childCount: postList.length,
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            isLoading
                ? Container()
                : SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "~ No more posts for now ~",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
