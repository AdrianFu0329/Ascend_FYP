import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SocialMediaCard extends StatefulWidget {
  final int index;
  final String postId;
  final List<ImageWithDimension> images;
  final String title;
  final String userId;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final String location;

  const SocialMediaCard({
    super.key,
    required this.postId,
    required this.index,
    required this.images,
    required this.userId,
    required this.likes,
    required this.title,
    required this.timestamp,
    required this.description,
    required this.location,
  });

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  int likeCount = 0;
  late ImageWithDimension firstImage;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length;
    firstImage = widget.images[0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToMediaPostScreen(),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    double imageHeight = firstImage.height > 250 ? 250 : firstImage.height;

    return SizedBox(
      width: 135,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    height: imageHeight,
                    child: firstImage.image,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: getUserData(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ContainerLoadingAnimation());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final userData = snapshot.data!;
                  final username = userData["username"] ?? "Unknown";
                  final photoUrl = userData["photoURL"] ?? "Unknown";

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            ProfilePicture(
                              userId: widget.userId,
                              photoURL: photoUrl,
                              radius: 12,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            Text(
                              username,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              likeCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.favorite,
                              color: Color.fromRGBO(247, 243, 237, 1),
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _navigateToMediaPostScreen() {
    Navigator.of(context).push(
      SlidingNav(
        builder: (context) => MediaPostScreen(
          postId: widget.postId,
          images: widget.images,
          title: widget.title,
          userId: widget.userId,
          likes: widget.likes,
          timestamp: widget.timestamp,
          description: widget.description,
          location: widget.location,
        ),
      ),
    );
  }
}
