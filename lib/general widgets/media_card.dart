import 'package:ascend_fyp/general%20widgets/post_loading_widget.dart';
import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/social%20media/screens/details/media_post_screen.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaCard extends StatefulWidget {
  final int index;
  final String postId;
  final dynamic media;
  final String title;
  final String userId;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final String location;
  final String type;
  final String videoURL;
  final String page;

  const MediaCard({
    super.key,
    required this.postId,
    required this.index,
    required this.media,
    required this.userId,
    required this.likes,
    required this.title,
    required this.timestamp,
    required this.description,
    required this.location,
    required this.type,
    required this.videoURL,
    required this.page,
  });

  @override
  State<MediaCard> createState() => MediaCardState();
}

class MediaCardState extends State<MediaCard> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late List<String> likes;
  bool isLiked = false;
  ImageWithDimension? firstImage;
  VideoPlayerController? videoController;
  double? imageHeight;
  double? videoHeight;
  double? videoAspectRatio;
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    likes = widget.likes;
    if (widget.type == 'Images') {
      firstImage = widget.media[0];
      imageHeight = widget.page == "Profile"
          ? (firstImage!.height > 200 ? 200 : firstImage?.height)
          : (firstImage!.height > 250 ? 250 : firstImage?.height);
    } else if (widget.type == 'Video') {
      initializeVideoController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.type == 'Images') {
      firstImage = widget.media[0];
      imageHeight = widget.page == "Profile"
          ? (firstImage!.height > 200 ? 200 : firstImage?.height)
          : (firstImage!.height > 250 ? 250 : firstImage?.height);
    } else if (widget.type == 'Video') {
      initializeVideoController();
    }
  }

  @override
  void dispose() {
    if (widget.type == 'Video' && videoController != null) {
      videoController!.pause();
    }
    super.dispose();
  }

  Future<void> initializeVideoController() async {
    try {
      setState(() {
        videoController = widget.media;
        videoHeight = videoController!.value.size.height > 200
            ? 200
            : videoController!.value.size.height;
        videoAspectRatio = videoController!.value.aspectRatio;
      });

      videoController!.pause();
      videoController!.addListener(() {
        if (videoController!.value.isPlaying != isPlaying.value) {
          isPlaying.value = videoController!.value.isPlaying;
        }
      });
    } catch (e) {
      debugPrint("Error loading video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PostLoadingWidget();
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
    return Container(
      height: widget.page == 'Profile' ? 290 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: widget.page == "Profile" ? 200 : null,
                  child: widget.type == 'Images'
                      ? (firstImage != null
                          ? CachedNetworkImage(
                              imageUrl: firstImage!.imageURL,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              height: imageHeight,
                            )
                          : Container())
                      : videoController != null &&
                              videoController!.value.isInitialized
                          ? FittedBox(
                              fit: BoxFit.fitWidth,
                              child: SizedBox(
                                width: videoController!.value.size.width,
                                height: videoController!.value.size.height,
                                child: VideoPlayer(videoController!),
                              ),
                            )
                          : Container(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            likes.length.toString(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMediaPostScreen() async {
    final result = await Navigator.of(context).push(
      SlidingNav(
        builder: (context) => MediaPostScreen(
          postId: widget.postId,
          media: widget.type == "Video" ? widget.videoURL : widget.media,
          title: widget.title,
          userId: widget.userId,
          likes: widget.likes,
          timestamp: widget.timestamp,
          description: widget.description,
          location: widget.location,
          type: widget.type,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        likes = result;
      });
    }
    // Reset video controller only if it was not playing
    if (widget.type == 'Video') {
      initializeVideoController();
    }

    // final result = await MediaPostScreen.show(
    //   context,
    //   postId: widget.postId,
    //   media: widget.media,
    //   title: widget.title,
    //   userId: widget.userId,
    //   likes: widget.likes,
    //   timestamp: widget.timestamp,
    //   description: widget.description,
    //   location: widget.location,
    //   type: widget.type,
    // );
  }
}
