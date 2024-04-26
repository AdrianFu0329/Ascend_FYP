import 'package:ascend_fyp/custom_widgets/button.dart';
import 'package:ascend_fyp/custom_widgets/loading.dart';
import 'package:ascend_fyp/geolocation/Geolocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../database/database_service.dart';
import 'package:intl/intl.dart';

class PostInteractionBar extends StatefulWidget {
  final List<String> likes;
  final String postId;
  const PostInteractionBar({
    super.key,
    required this.likes,
    required this.postId,
  });

  @override
  State<PostInteractionBar> createState() => _PostInteractionBarState();
}

class _PostInteractionBarState extends State<PostInteractionBar> {
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
        widget.likes.add(currentUser.email!);
      } else {
        likeCount--;
        widget.likes.remove(currentUser.email);
      }
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    postRef.update({'likes': widget.likes});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      style: Theme.of(context).textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Comment Something...',
                        hintStyle: Theme.of(context).textTheme.bodySmall,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(247, 243, 237, 1),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(247, 243, 237, 1),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color.fromRGBO(247, 243, 237, 1),
                      size: 20,
                    ),
                    onPressed: () {
                      // Implement sending the comment
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  icon: Icons.favorite_border,
                  pressedIcon: Icons.favorite,
                  defaultColor: const Color.fromRGBO(247, 243, 237, 1),
                  pressedColor: Colors.red,
                  onPressed: () {
                    onLikePressed();
                  },
                  isLiked: isLiked,
                  size: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    likeCount.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MediaPostScreen extends StatefulWidget {
  final String postId;
  final ImageWithDimension image;
  final String title;
  final String user;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;
  final Function(List<String>) updateLikes;

  const MediaPostScreen({
    super.key,
    required this.postId,
    required this.image,
    required this.title,
    required this.user,
    required this.likes,
    required this.timestamp,
    required this.description,
    required this.coordinates,
    required this.updateLikes,
  });

  @override
  State<MediaPostScreen> createState() => _MediaPostScreenState();
}

class _MediaPostScreenState extends State<MediaPostScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  late int likeCount;

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
        widget.likes.add(currentUser.email!);
      } else {
        likeCount--;
        widget.likes.remove(currentUser.email);
      }
    });

    widget.updateLikes(widget.likes);
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = widget.timestamp.toDate();
    String formatted = DateFormat('MMM dd, yyyy').format(dateTime);
    double latitude = widget.coordinates['latitude'] ?? 0.0;
    double longitude = widget.coordinates['longitude'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            widget.updateLikes(widget.likes);
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.user,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: FutureBuilder<String?>(
          future: GeoLocation().getCityFromCoordinates(latitude, longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoadingAnimation();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              String city = snapshot.data ?? "Unknown";
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.image.image,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            "$formatted \n$city",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PostInteractionBar(
                          likes: widget.likes,
                          postId: widget.postId,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
