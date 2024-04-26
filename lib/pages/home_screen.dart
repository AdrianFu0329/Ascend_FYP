import 'package:ascend_fyp/custom_widgets/button.dart';
import 'package:ascend_fyp/custom_widgets/loading.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../database/database_service.dart';

class SocialMediaCard extends StatefulWidget {
  final int index;
  final ImageWithDimension image;
  final String title;
  final String user;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;

  const SocialMediaCard({
    super.key,
    required this.index,
    required this.image,
    required this.user,
    required this.likes,
    required this.title,
    required this.timestamp,
    required this.description,
    required this.coordinates,
  });

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length;
    isLiked = widget.likes.contains(currentUser.email);
  }

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked == true) {
        likeCount++;
      } else {
        likeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight = (widget.image.height) / 3;
    double cardHeight =
        widget.index == 0 ? imageHeight + 75.0 : imageHeight + 100.0;

    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          SlidingNav(
            builder: (context) => MediaPostScreen(
              image: widget.image,
              title: widget.title,
              user: widget.user,
              likes: widget.likes,
              timestamp: widget.timestamp,
              description: widget.description,
              coordinates: widget.coordinates,
            ),
          ),
        ),
      },
      child: SizedBox(
        width: 135,
        height: cardHeight,
        child: Card(
          elevation: 4.0,
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: widget.image.image),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.user,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            likeCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          CustomButton(
                            icon: Icons.favorite_border,
                            pressedIcon: Icons.favorite,
                            defaultColor:
                                const Color.fromRGBO(247, 243, 237, 1),
                            pressedColor: Colors.red,
                            onPressed: () {
                              onLikePressed();
                            },
                            isLiked: isLiked,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                      image: posts[index].image,
                      title: posts[index].title,
                      user: posts[index].user,
                      likes: posts[index].likes,
                      timestamp: posts[index].timestamp,
                      description: posts[index].description,
                      coordinates: posts[index].coordinates,
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
