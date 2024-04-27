import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/social_media_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../database/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> updateLikes(String postId, List<String> updatedLikes) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(postId);
    await postRef.update({'likes': updatedLikes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          FutureBuilder<List<Post>>(
            future: getPostsFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: CustomLoadingAnimation(),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else {
                List<Post> posts = snapshot.data!;
                return SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return SocialMediaCard(
                      index: index,
                      postId: posts[index].postId,
                      image: posts[index].image,
                      title: posts[index].title,
                      user: posts[index].user,
                      likes: List<String>.from(posts[index].likes),
                      timestamp: posts[index].timestamp,
                      description: posts[index].description,
                      coordinates: posts[index].coordinates,
                      updateLikes: (updatedLikes) {
                        updateLikes(posts[index].postId, updatedLikes);
                      },
                    );
                  },
                  childCount: posts.length,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
