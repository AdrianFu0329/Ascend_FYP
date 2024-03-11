import 'package:ascend_fyp/custom_widgets/button.dart';
import 'package:ascend_fyp/custom_widgets/loading.dart';
import 'package:ascend_fyp/geolocation/Geolocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../database/database_service.dart';
import 'package:intl/intl.dart';

class PostInteractionBar extends StatefulWidget {
  final int likes;
  const PostInteractionBar({super.key, required this.likes});

  @override
  State<PostInteractionBar> createState() => _PostInteractionBarState();
}

class _PostInteractionBarState extends State<PostInteractionBar> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
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

class MediaPostScreen extends StatelessWidget {
  final ImageWithDimension image;
  final String title;
  final String user;
  final int likes;
  final Timestamp timestamp;
  final String description;
  final Map<String, double> coordinates;

  const MediaPostScreen({
    super.key,
    required this.image,
    required this.title,
    required this.user,
    required this.likes,
    required this.timestamp,
    required this.description,
    required this.coordinates,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = timestamp.toDate();
    String formatted = DateFormat('MMM dd, yyyy').format(dateTime);
    double latitude = coordinates['latitude'] ?? 0.0;
    double longitude = coordinates['longitude'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          user,
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
                        image.image,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            description,
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
                          likes: likes,
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
