import 'package:ascend_fyp/general%20widgets/profile_pic.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/getters/user_data.dart';

class CommentPost extends StatefulWidget {
  final String text;
  final String time;
  final String userId;
  final String postId;
  final String commentId;

  const CommentPost({
    super.key,
    required this.text,
    required this.time,
    required this.userId,
    required this.postId,
    required this.commentId,
  });

  @override
  State<CommentPost> createState() => _CommentPostState();
}

class _CommentPostState extends State<CommentPost> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    bool isCurrentUser = currentUser.uid == widget.userId;
    bool isDeletingComment = false;

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

    Future<bool> onDeleteCommentPressed() async {
      try {
        setState(() {
          isDeletingComment = true;
        });
        final DatabaseReference commentRef = FirebaseDatabase.instance
            .ref()
            .child('posts')
            .child(widget.postId)
            .child('comments')
            .child(widget.commentId);

        await commentRef.remove();

        setState(() {
          isDeletingComment = false;
        });
        return true;
      } catch (error) {
        setState(() {
          isDeletingComment = true;
        });
        return false;
      }
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FutureBuilder<Map<String, dynamic>>(
            future: getUserData(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CustomLoadingAnimation());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userData = snapshot.data!;
                final username = userData['username'] ?? 'Unknown';
                final photoUrl = userData['photoURL'] ?? 'Unknown';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Merriweather Sans',
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(211, 211, 211, 1),
                              ),
                            ),
                          ],
                        ),
                        isCurrentUser
                            ? PopupMenuButton(
                                iconColor:
                                    const Color.fromRGBO(247, 243, 237, 1),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "Delete Comment",
                                    child: Text("Delete Comment"),
                                  )
                                ],
                                onSelected: (value) {
                                  showMessage(
                                    "Are you sure you want to delete your comment?",
                                    true,
                                    onYesPressed: () async {
                                      bool isDeleted =
                                          await onDeleteCommentPressed();

                                      if (isDeleted) {
                                        showMessage(
                                          "Comment deleted successfully",
                                          false,
                                        );
                                      } else {
                                        showMessage(
                                          "Unable to delete comment. Try again later...",
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
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Text(
                        widget.text,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Text(
                        widget.time,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Merriweather Sans',
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(211, 211, 211, 1),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        if (isDeletingComment)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CustomLoadingAnimation(),
              ),
            ),
          ),
      ],
    );
  }
}
