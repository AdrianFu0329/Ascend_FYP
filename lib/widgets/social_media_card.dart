import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:ascend_fyp/widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Map<String, double> coordinates;
  final Function(List<String>) updateLikes;

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
    required this.coordinates,
    required this.updateLikes,
  });

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard> {
  late int likeCount;
  late ImageWithDimension firstImage;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length;
    firstImage = widget.images[0];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
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
    double imageHeight = (firstImage.height) / 3;
    double cardHeight =
        widget.index == 0 ? imageHeight + 75.0 : imageHeight + 100.0;

    return SizedBox(
      width: 135,
      height: cardHeight,
      child: Card(
        elevation: 4.0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: widget.images.isNotEmpty
                    ? firstImage.image
                    : Image.asset(
                        "lib/assets/images/default_profile_image.png"),
              ),
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
                    Row(
                      children: [
                        ProfilePicture(
                          userId: widget.userId,
                          photoURL: photoUrl,
                          radius: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          username,
                          style: Theme.of(context).textTheme.bodySmall,
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
          coordinates: widget.coordinates,
          updateLikes: widget.updateLikes,
        ),
      ),
    );
  }
}
