import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/general%20widgets/post_loading_widget.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_media_card.dart';
import 'package:ascend_fyp/models/video_with_dimension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CurrentUserPosts extends StatefulWidget {
  const CurrentUserPosts({super.key});

  @override
  State<CurrentUserPosts> createState() => _CurrentUserPostsState();
}

class _CurrentUserPostsState extends State<CurrentUserPosts> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: getPostsFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingAnimation());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> postList = snapshot.data!.docs;
            List<DocumentSnapshot> filteredPostsList = postList.where((doc) {
              String ownerUserId = doc['userId'];
              return ownerUserId == currentUser.uid;
            }).toList();

            return filteredPostsList.isNotEmpty
                ? MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: filteredPostsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = filteredPostsList[index];
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

                      return FutureBuilder<dynamic>(
                        future: type == "Images"
                            ? getPostImg(photoURLs)
                            : getPostVideo(videoURL),
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
                            if (type == "Images") {
                              List<ImageWithDimension> images = snapshot.data!;
                              return ProfileMediaCard(
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
                            } else {
                              VideoWithDimension video = snapshot.data!;
                              return ProfileMediaCard(
                                index: index,
                                postId: postId,
                                media: video,
                                title: title,
                                userId: userId,
                                likes: likes,
                                timestamp: timestamp,
                                description: description,
                                location: location,
                                type: type,
                              );
                            }
                          }
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text("No posts yet... Make one today!"),
                  );
          }
        },
      ),
    );
  }
}
