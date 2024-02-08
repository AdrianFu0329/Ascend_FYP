import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Post {
  final String title;
  final ImageWithDimension image;
  final int likes;
  final String user;

  Post({
    required this.title,
    required this.image,
    required this.likes,
    required this.user,
  });
}

class ImageWithDimension {
  final Widget image;
  final double height;
  final double width;

  ImageWithDimension(
      {required this.image, required this.height, required this.width});
}

Future<List<Post>> getPostsFromDatabase() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    List<Post> posts = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String title = doc['title'];
      ImageWithDimension image = await getPostImg(doc.id);
      int likes = doc['likes'];
      String user = doc['user'];

      Post post = Post(
        title: title,
        image: image,
        likes: likes,
        user: user,
      );
      posts.add(post);
    }

    return posts;
  } catch (e) {
    Center(child: Text('Error getting posts: $e'));
    return []; // Return an empty list in case of error
  }
}

Future<ImageWithDimension> getPostImg(String path) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child("posts/$path.png");
    String imgDownload = await ref.getDownloadURL();
    Image imageWidget = Image.network(
      imgDownload,
      fit: BoxFit.fitHeight,
    );

    Completer<ImageInfo> completer = Completer<ImageInfo>();
    imageWidget.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info);
        },
      ),
    );

    ImageInfo imageInfo = await completer.future;
    double imageHeight = imageInfo.image.height.toDouble();
    double imageWidth = imageInfo.image.width.toDouble();

    return ImageWithDimension(
      image: imageWidget,
      height: imageHeight,
      width: imageWidth,
    );
  } catch (e) {
    return ImageWithDimension(
      image: Center(child: Text('Error getting image: $e')),
      height: 0,
      width: 0,
    );
  }
}
