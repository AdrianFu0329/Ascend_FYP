import 'package:ascend_fyp/widgets/button.dart';
import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/media_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SocialMediaCard extends StatefulWidget {
  final int index;
  final String postId;
  final ImageWithDimension image;
  final String title;
  final String user;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;
  final Function(List<String>) updateLikes;

  const SocialMediaCard({
    super.key,
    required this.postId,
    required this.index,
    required this.image,
    required this.user,
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
  final currentUser = FirebaseAuth.instance.currentUser!;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length;
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
              postId: widget.postId,
              image: widget.image,
              title: widget.title,
              user: widget.user,
              likes: widget.likes,
              timestamp: widget.timestamp,
              description: widget.description,
              coordinates: widget.coordinates,
              updateLikes: widget.updateLikes,
            ),
          ),
        )
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
                      /*Row(
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
                          const SizedBox(width: 8),
                          Text(
                            likeCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chat_bubble,
                            color: Color.fromRGBO(247, 243, 237, 1),
                            size: 15,
                          ),
                        ],
                      ),*/
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
