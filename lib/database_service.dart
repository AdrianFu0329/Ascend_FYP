import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Post {
  final String title;
  final Widget imageUrl;
  final int likes;
  final String user;

  Post({
    required this.title,
    required this.imageUrl,
    required this.likes,
    required this.user,
  });
}

Future<List<Post>> getPostsFromDatabase() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    List<Post> posts = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String title = doc['title'];
      //String imageUrl = await getDownloadUrl(doc['imageUrl']);
      Widget imageUrl = await getPostImgURL(doc.id);
      int likes = doc['likes'];
      String user = doc['user'];

      Post post = Post(
        title: title,
        imageUrl: imageUrl,
        likes: likes,
        user: user,
      );
      posts.add(post);
    }

    return posts;
  } catch (e) {
    print('Error getting posts: $e');
    return []; // Return an empty list in case of error
  }
}

Future<Widget> getPostImgURL(String path) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child("posts/$path.png");
    String downloadUrl = await ref.getDownloadURL();
    return Image.network(
      downloadUrl,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  } catch (e) {
    return Center(
        child: Text(
            'Error getting download URL: $e')); // Return an empty string in case of error
  }
}
