import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_media_card.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  @override
  void initState() {
    refreshProfileData();
    checkIfFollowed();
    super.initState();
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
      photoURL = userData["photoURL"] ?? "";
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
              child: FutureBuilder(
                future: getUserData(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingAnimation();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    Map<String, dynamic> userData =
                        snapshot.data as Map<String, dynamic>;
                    username = userData["username"] ?? "Unknown";
                    description = userData["description"] == ""
                        ? "Empty~~ Add one today!"
                        : userData["description"];
                    email = userData['email'] ?? "Unknown";
                    photoURL = userData['photoURL'] ?? "";
                    followers = userData['followers'] ?? [];
                    following = userData['following'] ?? [];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              followers.length.toString(),
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
                                              following.length.toString(),
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
                                  username,
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
                    );
                  }
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: getPostsForCurrentUser(widget.userId),
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
                } else {
                  List postList = snapshot.data!.docs;
                  return postList.isNotEmpty
                      ? SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot doc = postList[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            String postId = data['postId'];
                            String title = data['title'];
                            List<String> imageURLs =
                                List<String>.from(data['imageURLs']);
                            List<String> likes =
                                List<String>.from(data['likes']);
                            String userId = data['userId'];
                            Timestamp timestamp = data['timestamp'];
                            String description = data['description'];
                            String location = data['location'];

                            return FutureBuilder<List<ImageWithDimension>>(
                              future: getPostImg(imageURLs),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CustomLoadingAnimation();
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      "An unexpected error occurred. Try again later...",
                                    ),
                                  );
                                } else {
                                  List<ImageWithDimension> images =
                                      snapshot.data!;
                                  return ProfileMediaCard(
                                    index: index,
                                    postId: postId,
                                    images: images,
                                    title: title,
                                    userId: userId,
                                    likes: likes,
                                    timestamp: timestamp,
                                    description: description,
                                    location: location,
                                  );
                                }
                              },
                            );
                          },
                          childCount: postList.length,
                        )
                      : const SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              "No posts from this user yet...",
                            ),
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
