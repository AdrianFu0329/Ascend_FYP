import 'package:ascend_fyp/getters/user_data.dart';
import 'package:ascend_fyp/models/image_with_dimension.dart';
import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/profile/screens/details/user_profile_screen.dart';
import 'package:ascend_fyp/social%20media/widgets/like_button.dart';
import 'package:ascend_fyp/social%20media/widgets/comment_card.dart';
import 'package:ascend_fyp/social%20media/widgets/image_page_view.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostInteractionBar extends StatefulWidget {
  final List<String> likes;
  final String postId;
  final String userId;
  const PostInteractionBar({
    super.key,
    required this.likes,
    required this.postId,
    required this.userId,
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
    super.initState();
    likeCount = widget.likes.length;
    isLiked = widget.likes.contains(currentUser.uid);
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
      } else {
        likeCount--;
        widget.likes.remove(currentUser.uid);
      }
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    postRef.update({'likes': widget.likes});
  }

  void addComment(String text) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "comment": text,
      "timestamp": Timestamp.now(),
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
  final List<ImageWithDimension> images;
  final String title;
  final String userId;
  final List<String> likes;
  final Timestamp timestamp;
  final String description;
  final String location;

  const MediaPostScreen({
    super.key,
    required this.postId,
    required this.images,
    required this.title,
    required this.userId,
    required this.likes,
    required this.timestamp,
    required this.description,
    required this.location,
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

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
        widget.likes.add(currentUser.uid);
      } else {
        likeCount--;
        widget.likes.remove(currentUser.uid);
      }
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    postRef.update({'likes': widget.likes});
  }

  String fromDateToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formatted = DateFormat('MMM dd, yyyy').format(dateTime);
    return formatted;
  }

  Future<bool> onDeletePostPressed() async {
    setState(() {
      isDeletingPost = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseStorage storage = FirebaseStorage.instance;

      // Firestore references
      DocumentReference postDocRef =
          firestore.collection('posts').doc(widget.postId);
      CollectionReference commentsCollectionRef =
          postDocRef.collection('comments');

      // Get all comments for the post
      QuerySnapshot commentsSnapshot = await commentsCollectionRef.get();
      WriteBatch batch = firestore.batch();

      for (DocumentSnapshot doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await postDocRef.delete();

      // Storage reference to the folder containing images
      Reference imagesFolderRef = storage.ref().child('posts/${widget.postId}');

      ListResult result = await imagesFolderRef.listAll();
      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }

      return true;
    } catch (error) {
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
          double imgHeight = widget.images[0].height;
          double maxHeight = imgHeight > 500 ? 500 : imgHeight;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color.fromRGBO(247, 243, 237, 1),
                ),
                onPressed: () {
                  Navigator.pop(context, widget.likes);
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
                      ImagePageView(
                        images: widget.images,
                        maxHeight: maxHeight,
                      ),
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
                      const SizedBox(height: 24),
                      PostInteractionBar(
                        likes: widget.likes,
                        postId: widget.postId,
                        userId: widget.userId,
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("posts")
                            .doc(widget.postId)
                            .collection("comments")
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CustomLoadingAnimation(),
                            );
                          }

                          return ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs.map((doc) {
                              final commentData =
                                  doc.data() as Map<String, dynamic>;
                              return CommentPost(
                                text: commentData["comment"],
                                userId: commentData["userId"],
                                postId: widget.postId,
                                commentId: doc.id,
                                time:
                                    fromDateToString(commentData["timestamp"]),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
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
                          child: ContainerLoadingAnimation(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}