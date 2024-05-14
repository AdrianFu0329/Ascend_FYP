import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/social_media_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../database/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<QuerySnapshot> postsStream;

  @override
  void initState() {
    super.initState();
    postsStream = getPostsFromDatabase();
  }

  Future<void> refreshPosts() async {
    setState(() {
      postsStream = getPostsFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                } else {
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
                            List<ImageWithDimension> images = snapshot.data!;
                            return SocialMediaCard(
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
