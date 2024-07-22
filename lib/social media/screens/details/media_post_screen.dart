import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/models/video_with_dimension.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/profile/screens/details/user_profile_screen.dart';
import 'package:ascend_fyp/social%20media/widgets/like_button.dart';
import 'package:ascend_fyp/social%20media/widgets/comment_card.dart';
import 'package:ascend_fyp/social%20media/widgets/image_page_view.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class PostInteractionBar extends StatefulWidget {
  final List<String> likes;
  final Function(int) onLikeCountChanged;
  final String postId;
  final String userId;
  const PostInteractionBar({
    super.key,
    required this.likes,
    required this.postId,
    required this.userId,
    required this.onLikeCountChanged,
  });

  @override
  State<PostInteractionBar> createState() => _PostInteractionBarState();
}

class _PostInteractionBarState extends State<PostInteractionBar> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  late int likeCount;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    likeCount = widget.likes.length;
    isLiked = widget.likes.contains(currentUser.uid);
    super.initState();
  }

  void _showMessage(String message, bool confirm,
      {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm) {
                  if (onYesPressed != null) {
                    onYesPressed();
                  }
                } else {
                  if (onOKPressed != null) {
                    onOKPressed();
                  }
                }
              },
              child: Text(
                confirm ? 'Yes' : 'OK',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            confirm
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked == true) {
        likeCount++;
        widget.likes.add(currentUser.uid);
        widget.onLikeCountChanged(likeCount);
      } else {
        likeCount--;
        widget.likes.remove(currentUser.uid);
        widget.onLikeCountChanged(likeCount);
      }
    });
    DatabaseReference postNew =
        FirebaseDatabase.instance.ref('posts/${widget.postId}');
    postNew.update({'likes': widget.likes});
  }

  void addComment(String text) {
    DatabaseReference commentsRef =
        FirebaseDatabase.instance.ref('posts/${widget.postId}/comments').push();
    commentsRef.set({
      "comment": text,
      "timestamp": ServerValue.timestamp,
      "userId": FirebaseAuth.instance.currentUser!.uid,
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
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      controller: commentController,
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
                      if (commentController.text.isEmpty) {
                        _showMessage(
                          "Please input a comment before sending...",
                          false,
                        );
                      } else {
                        addComment(commentController.text);
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LikeButton(
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
  final dynamic media;
  final String title;
  final String userId;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final String location;
  final String type;
  final Function(bool)? isDeleted;

  const MediaPostScreen({
    super.key,
    required this.postId,
    required this.media,
    required this.title,
    required this.userId,
    required this.likes,
    required this.timestamp,
    required this.description,
    required this.location,
    required this.type,
    required this.isDeleted,
  });

  @override
  State<MediaPostScreen> createState() => _MediaPostScreenState();
}

class _MediaPostScreenState extends State<MediaPostScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  int likeCount = 0;
  late int currentIndex = 0;
  bool isDeletingPost = false;
  bool isDeleted = false;
  VideoPlayerController? videoController;
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  VideoWithDimension? video;
  bool videoLoadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == "Video") {
      initializeVideoController();
    }
    setState(() {
      likeCount = widget.likes.length;
    });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  void initializeVideoController() async {
    try {
      Uri videoUri = Uri.parse(widget.media);
      VideoPlayerController controller =
          VideoPlayerController.networkUrl(videoUri);

      await controller.initialize();

      double height = controller.value.size.height;
      double width = controller.value.size.width;

      VideoWithDimension videoWithDimension = VideoWithDimension(
        videoController: controller,
        height: height,
        width: width,
        aspectRatio: width / height,
      );

      videoController = videoWithDimension.videoController;

      if (mounted) {
        setState(() {
          video = videoWithDimension;
          videoLoadFailed = false;
        });
      }

      videoController!.play();
      videoController!.addListener(() {
        if (videoController!.value.isPlaying != isPlaying.value) {
          isPlaying.value = videoController!.value.isPlaying;
        }
      });
    } catch (e) {
      debugPrint("Error loading video: $e");
      setState(() {
        videoLoadFailed = true;
      });
    }
  }

  void resetVideoController() {
    videoController?.seekTo(Duration.zero);
    videoController?.play();
  }

  String fromDateToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formatted = DateFormat('MMM dd, yyyy').format(dateTime);
    return formatted;
  }

  String fromServerTimeToString(int milliseconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String formatted = DateFormat('MMM dd, yyyy').format(dateTime);
    return formatted;
  }

  Future<bool> onDeletePostPressed() async {
    setState(() {
      isDeletingPost = true;
    });

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      FirebaseDatabase database = FirebaseDatabase.instance;

      // Delete post in Realtime Database
      DatabaseReference postRef = database.ref('posts/${widget.postId}');
      await postRef.remove();

      // Storage reference to the folder containing images
      Reference imagesFolderRef = storage.ref().child('posts/${widget.postId}');

      // List all files in the images folder and delete them
      ListResult result = await imagesFolderRef.listAll();
      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }
      setState(() {
        isDeleted = true;
      });
      return true;
    } catch (error) {
      debugPrint('Error deleting post: $error');
      return false;
    } finally {
      setState(() {
        isDeletingPost = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatted = fromDateToString(widget.timestamp);
    final currentUser = FirebaseAuth.instance.currentUser!;
    bool isCurrentUser = currentUser.uid == widget.userId;

    void showMessage(String message, bool confirm,
        {VoidCallback? onYesPressed, VoidCallback? onOKPressed}) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            content: Text(
              message,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (confirm) {
                    if (onYesPressed != null) {
                      onYesPressed();
                    }
                  } else {
                    if (onOKPressed != null) {
                      onOKPressed();
                    }
                  }
                },
                child: Text(
                  confirm ? 'Yes' : 'OK',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              confirm
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    )
                  : Container(),
            ],
          );
        },
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          final username = userData["username"] ?? "Unknown";
          final photoUrl = userData["photoURL"] ?? "Unknown";
          String city = widget.location;
          double mediaHeight;
          if (widget.type == "Images") {
            if (widget.media is List) {
              if (widget.media.isNotEmpty &&
                  widget.media[0] is ImageWithDimension) {
                mediaHeight = widget.media[0].height;
              } else {
                // Handle the case where the list is empty or contains unexpected objects
                mediaHeight = 0.0;
              }
            } else {
              // Handle the case where widget.media is not a list
              mediaHeight = 0.0;
            }
          } else {
            mediaHeight = video?.height ?? 0.0;
          }
          double maxHeight = mediaHeight > 500 ? 500 : mediaHeight;

          return PopScope(
            canPop: false,
            onPopInvoked: ((didPop) async {
              if (didPop) {
                return;
              }
              Navigator.pop(context, {'likes': widget.likes});
              debugPrint(likeCount.toString());
              dispose();
            }),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color.fromRGBO(247, 243, 237, 1),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {'likes': widget.likes});
                    dispose();
                  },
                ),
                title: Row(
                  children: [
                    ProfilePicture(
                      userId: widget.userId,
                      photoURL: photoUrl,
                      radius: 15,
                      onTap: () {
                        Navigator.of(context).push(
                          SlidingNav(
                            builder: (context) => UserProfileScreen(
                                userId: widget.userId,
                                isCurrentUser: isCurrentUser),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          SlidingNav(
                            builder: (context) => UserProfileScreen(
                                userId: widget.userId,
                                isCurrentUser: isCurrentUser),
                          ),
                        );
                      },
                      child: Text(
                        username,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                actions: [
                  isCurrentUser
                      ? PopupMenuButton(
                          iconColor: const Color.fromRGBO(247, 243, 237, 1),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "Delete Post",
                              child: Text("Delete Post"),
                            )
                          ],
                          onSelected: (value) {
                            showMessage(
                              "Are you sure you want to delete your post?",
                              true,
                              onYesPressed: () async {
                                setState(() {
                                  isDeletingPost = true;
                                });
                                bool isDeleted = await onDeletePostPressed();

                                if (isDeleted) {
                                  showMessage(
                                    "Post deleted successfully",
                                    false,
                                    onOKPressed: () {
                                      Navigator.of(context).pop();
                                      if (widget.isDeleted != null) {
                                        widget.isDeleted!(true);
                                      }
                                    },
                                  );
                                } else {
                                  showMessage(
                                    "Unable to delete post. Try again later...",
                                    false,
                                  );
                                }
                              },
                            );
                          },
                        )
                      : Container(),
                ],
              ),
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.type == "Video"
                            ? videoLoadFailed
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "lib/assets/images/error_loading_posts.png",
                                          width: 250,
                                          height: 250,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Oops, failed to load the post!",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  )
                                : videoController != null &&
                                        videoController!.value.isInitialized
                                    ? Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (videoController!
                                                .value.isPlaying) {
                                              videoController!.pause();
                                            } else {
                                              videoController!.play();
                                            }
                                          },
                                          child: ValueListenableBuilder<bool>(
                                            valueListenable: isPlaying,
                                            builder:
                                                (context, isPlaying, child) {
                                              return Stack(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio:
                                                        videoController!
                                                            .value.aspectRatio,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        VideoPlayer(
                                                            videoController!),
                                                        if (!isPlaying)
                                                          const Icon(
                                                            Icons
                                                                .play_arrow_rounded,
                                                            size: 70,
                                                            color: Colors.white,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child:
                                                        VideoProgressIndicator(
                                                      videoController!,
                                                      allowScrubbing: true,
                                                      colors:
                                                          VideoProgressColors(
                                                        playedColor: Colors.red,
                                                        bufferedColor: Colors
                                                            .grey.shade300,
                                                        backgroundColor: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : const CustomLoadingAnimation()
                            : ImagePageView(
                                images: widget.media,
                                maxHeight: maxHeight,
                              ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                          ],
                        ),
                        const SizedBox(height: 24),
                        PostInteractionBar(
                          likes: widget.likes,
                          postId: widget.postId,
                          userId: widget.userId,
                          onLikeCountChanged: (newLikeCount) {
                            likeCount = newLikeCount;
                          },
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<DatabaseEvent>(
                          stream: FirebaseDatabase.instance
                              .ref('posts/${widget.postId}/comments')
                              .orderByChild("timestamp")
                              .onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CustomLoadingAnimation(),
                              );
                            } else if (snapshot.data!.snapshot.value == null) {
                              return Container();
                            } else {
                              final commentsData = Map<String, dynamic>.from(
                                  snapshot.data!.snapshot.value
                                      as Map<dynamic, dynamic>);

                              return ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: commentsData.entries.map((entry) {
                                  final commentId = entry.key;
                                  final commentData = Map<String, dynamic>.from(
                                      entry.value as Map<dynamic, dynamic>);
                                  return CommentPost(
                                    text: commentData["comment"],
                                    userId: commentData["userId"],
                                    postId: widget.postId,
                                    commentId: commentId,
                                    time: fromServerTimeToString(
                                      commentData["timestamp"],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            "~END~",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Merriweather Sans',
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(211, 211, 211, 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    if (isDeletingPost)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CustomLoadingAnimation(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
