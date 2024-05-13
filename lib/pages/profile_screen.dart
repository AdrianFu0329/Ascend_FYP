import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/edit_profile_screen.dart';
import 'package:ascend_fyp/pages/welcome_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_media_card.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1), width: 1.5),
        ),
      ),
    );

    ButtonStyle logOutStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side:
              const BorderSide(color: Color.fromRGBO(194, 0, 0, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(
            "lib/assets/images/logo_noBg.png",
            width: 130,
            height: 50,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              style: logOutStyle,
              child: const Text('Log out'),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: getUserData(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomLoadingAnimation();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  Map<String, String> userData =
                      snapshot.data as Map<String, String>;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfilePicture(
                              userId: currentUser.uid,
                              photoURL: currentUser.photoURL ?? "Unknown",
                              radius: 40,
                            ),
                            ListTile(
                              title: Text(
                                userData["username"] ?? "Unknown",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Text(
                                userData["description"] == ""
                                    ? "Empty~~ Add one today!"
                                    : userData["description"]!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    SlidingNav(
                                      builder: (context) => EditProfileScreen(
                                        username: userData['username']!,
                                        email: userData['email']!,
                                        description:
                                            userData["description"] == ""
                                                ? "Empty~~ Add one today!"
                                                : userData["description"]!,
                                      ),
                                    ),
                                  );
                                },
                                style: buttonStyle,
                                child: const Text('Edit Profile'),
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
            stream: getPostsForCurrentUser(currentUser.uid),
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
                          List<String> likes = List<String>.from(data['likes']);
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
                            "No posts yet... Make one today!",
                          ),
                        ),
                      );
              }
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
