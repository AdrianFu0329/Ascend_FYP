import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileMediaCard extends StatefulWidget {
  final int index;
  final String postId;
  final List<ImageWithDimension> images;
  final String title;
  final String userId;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final String location;

  const ProfileMediaCard({
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
  State<ProfileMediaCard> createState() => ProfileMediaCardState();
}

class ProfileMediaCardState extends State<ProfileMediaCard> {
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
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomLoadingAnimation());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";

          return GestureDetector(
            onTap: () => _navigateToMediaPostScreen(),
            child: _buildCard(username, photoUrl),
          );
        }
      },
    );
  }

  Widget _buildCard(String username, String photoUrl) {
    double imageHeight = firstImage.height > 225 ? 225 : firstImage.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.white),
      ),
      child: SizedBox(
        width: 135,
        height: 300,
        child: Card(
          elevation: 4.0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
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
              ),
              const SizedBox(height: 4),
            ],
          ),
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